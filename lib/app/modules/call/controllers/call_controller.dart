import 'dart:async';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/services/webrtc_service.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' hide navigator;

class CallController extends GetxController {
  final WebRTCService _webRTCService = Get.find<WebRTCService>();

  // Reactive state
  final RxBool isMuted = false.obs;
  final RxBool isSpeakerOn = true.obs;
  final RxBool isCameraOff = false.obs;

  // Accessing WebRTCService states
  RxBool get isJoined => _webRTCService.isConnected;
  RxBool get isVideoCall => RxBool(!_webRTCService.isAudioOnly.value);
  RxString get remoteUserName => _webRTCService.remoteUserName;
  RxInt get callDurationSeconds => _webRTCService.callDurationSeconds;

  RTCVideoRenderer get localRenderer => _webRTCService.localRenderer;
  RTCVideoRenderer get remoteRenderer => _webRTCService.remoteRenderer;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> startCall({
    required String targetUserId,
    required String targetUserName,
    required bool videoCall,
  }) async {
    // Request permissions
    await [Permission.microphone, Permission.camera].request();

    // Only make the call if we are the initiator (not already in a ringing/connected state)
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    if (args['incoming'] == true) {
      return; // Already connecting via acceptCall
    }

    await _webRTCService.makeCall(targetUserId, targetUserName, !videoCall);
  }

  void toggleMute() {
    isMuted.toggle();
    _webRTCService.localRenderer.srcObject?.getAudioTracks().forEach((track) {
      track.enabled = !isMuted.value;
    });
  }

  void toggleSpeaker() {
    isSpeakerOn.toggle();
    // Speaker control is platform specific or needs a specialized plugin
  }

  void toggleCamera() {
    isCameraOff.toggle();
    _webRTCService.localRenderer.srcObject?.getVideoTracks().forEach((track) {
      track.enabled = !isCameraOff.value;
    });
  }

  void switchCamera() {
    _webRTCService.localRenderer.srcObject?.getVideoTracks().forEach((track) {
      Helper.switchCamera(track);
    });
  }

  void endCall() {
    _webRTCService.endCall();
  }

  String get formattedDuration => _webRTCService.formattedDuration;

  @override
  void onClose() {
    super.onClose();
  }
}
