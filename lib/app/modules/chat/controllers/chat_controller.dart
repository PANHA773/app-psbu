import 'package:get/get.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../data/services/chat_service.dart';
import '../../../data/services/auth_service.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final Rx<ChatSender?> selectedUser = Rx<ChatSender?>(null);
  final RxMap<String, dynamic> currentUser = <String, dynamic>{}.obs;

  List<ChatSender> get recentConversations {
    final currentUserId = currentUser['_id']?.toString();
    final Map<String, ChatSender> uniqueUsers = {};

    for (var msg in messages) {
      if (msg.sender.id != currentUserId) {
        uniqueUsers[msg.sender.id] = msg.sender;
      }
      // If we have recipient info and it's not us
      if (msg.recipient != null && msg.recipient != currentUserId) {
        // We might need a full user object for recipient if it's not in the message list
      }
    }
    return uniqueUsers.values.toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchCurrentUser();
    fetchMessages();
  }

  Future<void> fetchCurrentUser() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
      }
    } catch (e) {
      print('❌ Failed to fetch current user: $e');
    }
  }

  void setSelectedUser(ChatSender user) {
    selectedUser.value = user;
  }

  Future<void> fetchMessages() async {
    try {
      isLoading.value = true;
      error.value = '';
      final fetchedMessages = await _chatService.getMessages();
      messages.assignAll(fetchedMessages);
    } catch (e) {
      print('❌ ChatController Error: $e');
      error.value = 'Failed to load messages: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    try {
      await _chatService.sendMessage(
        content,
        recipientId: selectedUser.value?.id,
      );
      fetchMessages(); // Refresh after sending
    } catch (e) {
      print('❌ Send Message Error: $e');
      Get.snackbar('Error', 'Failed to send message');
    }
  }
}
