import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:university_news_app/app/config.dart';
import '../../../data/models/announcement_model.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../data/services/chat_service.dart';
import '../../../data/services/auth_service.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

class ChatController extends GetxController {
  Future<void> editMessage(String messageId, String newContent) async {
    try {
      await _chatService.editMessage(messageId, newContent);
      final userId = selectedUser.value?.id;
      if (userId != null) {
        fetchConversationMessages(userId);
      }
    } catch (e) {
      print('Edit Message Error: $e');
      Get.snackbar('Error', 'Failed to edit message');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _chatService.deleteMessage(messageId);
      final userId = selectedUser.value?.id;
      if (userId != null) {
        fetchConversationMessages(userId);
      }
    } catch (e) {
      print('Delete Message Error: $e');
      Get.snackbar('Error', 'Failed to delete message');
    }
  }

  final ChatService _chatService = ChatService();
  final RxList<ChatSender> conversations = <ChatSender>[].obs;
  final RxList<ChatMessageModel> conversationMessages =
      <ChatMessageModel>[].obs;
  final RxList<AnnouncementModel> announcements = <AnnouncementModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isAnnouncementsLoading = false.obs;
  final RxBool isTypingInConversation = false.obs;
  final RxBool isOtherUserTyping = false.obs;
  final RxString error = ''.obs;
  final RxString announcementError = ''.obs;
  final Rx<ChatSender?> selectedUser = Rx<ChatSender?>(null);
  final RxMap<String, dynamic> currentUser = <String, dynamic>{}.obs;

  // Recording State
  final AudioRecorder _audioRecorder = AudioRecorder();
  final RxBool isRecording = false.obs;
  final RxInt recordingDuration = 0.obs;
  final RxString pendingRecordingPath = ''.obs;
  final RxInt pendingRecordingDuration = 0.obs;
  String? _recordingPath;
  Timer? _recordingTimer;
  Timer? _conversationRealtimeTimer;
  io.Socket? _announcementSocket;
  bool _isStartingRecording = false;
  bool _isFetchingConversation = false;
  bool _isFetchingAnnouncements = false;

  bool get isAdmin {
    final role = currentUser['role']?.toString().toLowerCase();
    return role == 'admin';
  }

  List<ChatSender> get recentConversations {
    return conversations;
  }

  @override
  void onInit() {
    super.onInit();
    fetchCurrentUser();
    fetchConversations();
    fetchAnnouncements();
    _connectAnnouncementSocket();
  }

  Future<void> fetchCurrentUser() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
      }
    } catch (e) {
      print('Failed to fetch current user: $e');
    }
  }

  Future<void> fetchAnnouncements({bool showLoader = true}) async {
    if (_isFetchingAnnouncements) return;
    try {
      _isFetchingAnnouncements = true;
      if (showLoader) isAnnouncementsLoading.value = true;
      announcementError.value = '';
      final items = await _chatService.getAnnouncements();
      announcements.assignAll(items);
      _sortAnnouncements();
    } catch (e) {
      print('Announcements Error: $e');
      announcementError.value = 'Failed to load announcements: $e';
    } finally {
      if (showLoader) isAnnouncementsLoading.value = false;
      _isFetchingAnnouncements = false;
    }
  }

  Future<void> sendAnnouncement(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    try {
      final created = await _chatService.sendAnnouncement(trimmed);
      _upsertAnnouncement(created);
    } catch (e) {
      print('Send Announcement Error: $e');
      Get.snackbar('Error', 'Failed to send announcement');
    }
  }

  Future<void> _connectAnnouncementSocket() async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) return;

    _announcementSocket?.disconnect();
    _announcementSocket?.dispose();

    _announcementSocket = io.io(
      AppConfig.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    _announcementSocket?.onConnect((_) {
      print('Connected to announcement socket');
    });

    _announcementSocket?.on('announcement_message', (data) {
      try {
        final parsed = _normalizeAnnouncementData(data);
        if (parsed == null) return;
        _upsertAnnouncement(parsed);
      } catch (e) {
        print('Announcement socket parse error: $e');
      }
    });

    _announcementSocket?.connect();
  }

  void setSelectedUser(ChatSender user) {
    selectedUser.value = user;
    isTypingInConversation.value = false;
    isOtherUserTyping.value = false;
    fetchConversationMessages(user.id);
  }

  void startRealtimeUpdates(String userId) {
    _conversationRealtimeTimer?.cancel();
    _conversationRealtimeTimer = Timer.periodic(const Duration(seconds: 2), (
      _,
    ) {
      fetchConversationMessages(userId, showLoader: false);
    });
  }

  void stopRealtimeUpdates() {
    _conversationRealtimeTimer?.cancel();
    _conversationRealtimeTimer = null;
  }

  void onDraftChanged(String value) {
    isTypingInConversation.value = value.trim().isNotEmpty;
  }

  // Hook for realtime typing events (socket/pusher) when backend support exists.
  void setOtherUserTyping(bool typing) {
    isOtherUserTyping.value = typing;
  }

  Future<void> fetchConversations() async {
    try {
      isLoading.value = true;
      error.value = '';
      final fetchedConversations = await _chatService.getConversations();
      conversations.assignAll(fetchedConversations);
    } catch (e) {
      print('ChatController Error: $e');
      error.value = 'Failed to load conversations: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchConversationMessages(
    String userId, {
    bool showLoader = true,
  }) async {
    if (_isFetchingConversation) return;
    try {
      _isFetchingConversation = true;
      if (showLoader) isLoading.value = true;
      error.value = '';
      final fetchedMessages = await _chatService.getConversationMessages(
        userId,
      );
      conversationMessages.assignAll(fetchedMessages);
    } catch (e) {
      print('ChatController Conversation Error: $e');
      error.value = 'Failed to load messages: $e';
    } finally {
      if (showLoader) isLoading.value = false;
      _isFetchingConversation = false;
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    try {
      await _chatService.sendMessage(
        content,
        recipientId: selectedUser.value?.id,
      );
      final userId = selectedUser.value?.id;
      if (userId != null) {
        fetchConversationMessages(userId);
      }
      fetchConversations();
      isTypingInConversation.value = false;
    } catch (e) {
      print('Send Message Error: $e');
      Get.snackbar('Error', 'Failed to send message');
    }
  }

  Future<void> startRecording() async {
    if (isRecording.value || _isStartingRecording) return;
    try {
      _isStartingRecording = true;
      await _clearPendingRecording(deleteFile: true);
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        _recordingPath =
            '${directory.path}/voice_msg_${DateTime.now().millisecondsSinceEpoch}.m4a';

        const config = RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
          bitRate: 128000,
          numChannels: 1,
        );
        await _audioRecorder.start(config, path: _recordingPath!);

        isRecording.value = true;
        recordingDuration.value = 0;
        _startRecordingTimer();
        print('Started recording at: $_recordingPath');
      }
    } catch (e) {
      print('Start Recording Error: $e');
      Get.snackbar('Error', 'Could not start recording');
    } finally {
      _isStartingRecording = false;
    }
  }

  Future<void> stopRecording() async {
    if (_isStartingRecording || !isRecording.value) return;
    try {
      final path = await _audioRecorder.stop();
      _stopRecordingTimer();
      isRecording.value = false;
      final duration = recordingDuration.value;
      recordingDuration.value = 0;

      if (path != null) {
        final file = File(path);
        final exists = await file.exists();
        final size = exists ? await file.length() : 0;
        if (!exists || size == 0) {
          print('Voice file invalid. exists=$exists size=$size path=$path');
          Get.snackbar('Error', 'Voice recording is empty. Please try again.');
          return;
        }
        pendingRecordingPath.value = path;
        pendingRecordingDuration.value = duration;
        Get.snackbar('Voice Ready', 'Tap send to deliver this voice message.');
      } else {
        Get.snackbar('Error', 'Recording failed. Please try again.');
      }
    } catch (e) {
      print('Stop Recording Error: $e');
      Get.snackbar('Error', 'Recording failed. Please try again.');
      isRecording.value = false;
      recordingDuration.value = 0;
    }
  }

  Future<void> cancelRecording() async {
    try {
      String? stoppedPath;
      if (isRecording.value) {
        stoppedPath = await _audioRecorder.stop();
      }
      _stopRecordingTimer();
      isRecording.value = false;
      recordingDuration.value = 0;

      await _deleteFileIfExists(stoppedPath ?? _recordingPath);
      await _clearPendingRecording(deleteFile: true);
      _recordingPath = null;
    } catch (e) {
      print('Cancel Recording Error: $e');
    }
  }

  Future<void> sendPendingRecording() async {
    final path = pendingRecordingPath.value;
    if (path.isEmpty) {
      Get.snackbar('Error', 'No voice recording to send.');
      return;
    }

    final sent = await _sendVoiceMessage(path);
    if (!sent) return;

    await _deleteFileIfExists(path);
    await _clearPendingRecording(deleteFile: false);
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      recordingDuration.value++;
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  Future<bool> _sendVoiceMessage(String path) async {
    try {
      final userId = selectedUser.value?.id;
      if (userId == null) return false;

      await _chatService.sendVoiceMessage(path, recipientId: userId);
      fetchConversationMessages(userId);
      fetchConversations();
      return true;
    } catch (e) {
      print('Send Voice Message Error: $e');
      Get.snackbar('Error', 'Failed to send voice message');
      return false;
    }
  }

  Future<void> _clearPendingRecording({required bool deleteFile}) async {
    if (deleteFile) {
      await _deleteFileIfExists(pendingRecordingPath.value);
    }
    pendingRecordingPath.value = '';
    pendingRecordingDuration.value = 0;
  }

  Future<void> _deleteFileIfExists(String? path) async {
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  AnnouncementModel? _normalizeAnnouncementData(dynamic data) {
    if (data is Map<String, dynamic>) {
      final raw = data['announcement'] ?? data['data'] ?? data;
      if (raw is Map<String, dynamic>) return AnnouncementModel.fromJson(raw);
      if (raw is Map) {
        return AnnouncementModel.fromJson(Map<String, dynamic>.from(raw));
      }
    }

    if (data is Map) {
      return AnnouncementModel.fromJson(Map<String, dynamic>.from(data));
    }

    return null;
  }

  void _upsertAnnouncement(AnnouncementModel item) {
    final index = announcements.indexWhere((a) => a.id == item.id);
    if (index >= 0) {
      announcements[index] = item;
    } else {
      announcements.add(item);
    }
    _sortAnnouncements();
  }

  void _sortAnnouncements() {
    announcements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  void onClose() {
    _conversationRealtimeTimer?.cancel();
    _announcementSocket?.disconnect();
    _announcementSocket?.dispose();
    _audioRecorder.dispose();
    _recordingTimer?.cancel();
    super.onClose();
  }
}
