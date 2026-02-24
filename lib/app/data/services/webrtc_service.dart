import 'package:flutter_webrtc/flutter_webrtc.dart' hide navigator;
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc show navigator;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';
import 'auth_service.dart';
import 'chat_service.dart';
import 'package:university_news_app/app/config.dart';
import 'dart:async';

class WebRTCService extends GetxService {
  IO.Socket? socket;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  // Renderers for UI
  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();

  // Call state
  final isCalling = false.obs;
  final isRinging = false.obs;
  final isConnected = false.obs;
  final isAudioOnly = true.obs;

  final remoteUserId = ''.obs;
  final remoteUserName = ''.obs;

  // Duration tracking
  final callDurationSeconds = 0.obs;
  Timer? _durationTimer;
  final ChatService _chatService = ChatService();

  @override
  void onInit() {
    super.onInit();
    _initRenderers();
    connectSocket();
    _setupCallListeners();
  }

  void _setupCallListeners() {
    ever(isRinging, (bool ringing) {
      if (ringing && !Get.currentRoute.contains('call')) {
        Get.toNamed('/incoming-call');
      }
    });

    ever(isConnected, (bool connected) {
      if (connected) {
        _startDurationTimer();
      } else {
        _stopDurationTimer();
      }
    });
  }

  @override
  void onClose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    _peerConnection?.dispose();
    socket?.disconnect();
    super.onClose();
  }

  Future<void> _initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  void connectSocket() {
    final token = AuthService.token;
    if (token == null) return;

    socket = IO.io(AppConfig.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'query': {'token': token},
    });

    socket?.onConnect((_) {
      print('Connected to signaling server');
    });

    socket?.on('incoming-call', (data) => _handleIncomingCall(data));
    socket?.on('call-accepted', (data) => _handleCallAccepted(data));
    socket?.on('call-rejected', (data) => _handleCallRejected(data));
    socket?.on('ice-candidate', (data) => _handleIceCandidate(data));
    socket?.on('call-ended', (_) => _cleanupCall());
  }

  Future<void> makeCall(
    String targetUserId,
    String targetUserName,
    bool audioOnly,
  ) async {
    isAudioOnly.value = audioOnly;
    remoteUserId.value = targetUserId;
    remoteUserName.value = targetUserName;
    isCalling.value = true;

    await _createPeerConnection();

    final offer = await _peerConnection?.createOffer({
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': !audioOnly,
    });

    if (offer != null) {
      await _peerConnection?.setLocalDescription(offer);
    }

    if (offer != null) {
      socket?.emit('make-call', {
        'to': targetUserId,
        'offer': offer.toMap(),
        'audioOnly': audioOnly,
        'callerName':
            (await AuthService.getCurrentUser())?['name'] ?? 'Unknown',
      });
    }
  }

  Future<void> acceptCall() async {
    isRinging.value = false;
    isConnected.value = true;

    // The peer connection should already be initialized in _handleIncomingCall
    final answer = await _peerConnection?.createAnswer();
    if (answer != null) {
      await _peerConnection?.setLocalDescription(answer);
    }

    if (answer != null) {
      socket?.emit('accept-call', {
        'to': remoteUserId.value,
        'answer': answer.toMap(),
      });
    }
  }

  void rejectCall() {
    socket?.emit('reject-call', {'to': remoteUserId.value});
    _cleanupCall();
  }

  void endCall() {
    socket?.emit('end-call', {'to': remoteUserId.value});
    _cleanupCall();
  }

  Future<void> _createPeerConnection() async {
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ],
    };

    final constraints = {
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': !isAudioOnly.value,
      },
      'optional': [],
    };

    _peerConnection = await createPeerConnection(configuration, constraints);

    _peerConnection?.onIceCandidate = (candidate) {
      socket?.emit('ice-candidate', {
        'to': remoteUserId.value,
        'candidate': candidate.toMap(),
      });
    };

    _peerConnection?.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams[0];
      }
    };

    _localStream = await _getUserMedia();
    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) {
        _peerConnection?.addTrack(track, _localStream!);
      });
    }

    localRenderer.srcObject = _localStream;
  }

  Future<MediaStream> _getUserMedia() async {
    final Map<String, dynamic> constraints = {
      'audio': true,
      'video': isAudioOnly.value
          ? false
          : {'facingMode': 'user', 'width': '640', 'height': '480'},
    };

    return await webrtc.navigator.mediaDevices.getUserMedia(constraints);
  }

  Future<void> _handleIncomingCall(Map<String, dynamic> data) async {
    remoteUserId.value = data['from'];
    remoteUserName.value = data['callerName'] ?? 'Unknown';
    isAudioOnly.value = data['audioOnly'] ?? true;
    isRinging.value = true;

    await _createPeerConnection();

    if (data['offer'] == null) return;
    final offer = RTCSessionDescription(
      data['offer']['sdp'],
      data['offer']['type'],
    );
    await _peerConnection?.setRemoteDescription(offer);
  }

  Future<void> _handleCallAccepted(Map<String, dynamic> data) async {
    isCalling.value = false;
    isConnected.value = true;

    if (data['answer'] == null) return;
    final answer = RTCSessionDescription(
      data['answer']['sdp'],
      data['answer']['type'],
    );
    await _peerConnection?.setRemoteDescription(answer);
  }

  void _handleCallRejected(Map<String, dynamic> data) {
    _cleanupCall();
    Get.snackbar('Call Rejected', '${remoteUserName.value} rejected your call');
  }

  void _handleIceCandidate(Map<String, dynamic> data) {
    if (data['candidate'] == null) return;
    final candidate = RTCIceCandidate(
      data['candidate']['candidate'],
      data['candidate']['sdpMid'],
      data['candidate']['sdpMLineIndex'],
    );
    _peerConnection?.addCandidate(candidate);
  }

  void _cleanupCall() {
    isCalling.value = false;
    isRinging.value = false;
    isConnected.value = false;
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _peerConnection?.dispose();
    _peerConnection = null;
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;

    _sendCallSummary();

    if (Get.currentRoute.contains('call') ||
        Get.currentRoute.contains('incoming')) {
      Get.back();
    }
  }

  // ── Duration & Summary ──────────────────────────────────────────
  void _startDurationTimer() {
    _durationTimer?.cancel();
    callDurationSeconds.value = 0;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      callDurationSeconds.value++;
    });
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  String get formattedDuration {
    final mins = (callDurationSeconds.value ~/ 60).toString().padLeft(2, '0');
    final secs = (callDurationSeconds.value % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Future<void> _sendCallSummary() async {
    if (callDurationSeconds.value <= 0 || remoteUserId.value.isEmpty) return;

    final type = isAudioOnly.value ? 'Voice Call' : 'Video Call';
    final summary = '[$type: $formattedDuration]';

    try {
      await _chatService.sendMessage(summary, recipientId: remoteUserId.value);
      print('✅ Call summary sent: $summary');
    } catch (e) {
      print('❌ Failed to send call summary: $e');
    }

    // Reset duration after sending
    callDurationSeconds.value = 0;
  }
}
