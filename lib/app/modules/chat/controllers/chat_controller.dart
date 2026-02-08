import 'package:get/get.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../data/services/chat_service.dart';
import '../../../data/services/auth_service.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final RxList<ChatSender> conversations = <ChatSender>[].obs;
  final RxList<ChatMessageModel> conversationMessages =
      <ChatMessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final Rx<ChatSender?> selectedUser = Rx<ChatSender?>(null);
  final RxMap<String, dynamic> currentUser = <String, dynamic>{}.obs;

  List<ChatSender> get recentConversations {
    return conversations;
  }

  @override
  void onInit() {
    super.onInit();
    fetchCurrentUser();
    fetchConversations();
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
    fetchConversationMessages(user.id);
  }

  Future<void> fetchConversations() async {
    try {
      isLoading.value = true;
      error.value = '';
      final fetchedConversations = await _chatService.getConversations();
      conversations.assignAll(fetchedConversations);
    } catch (e) {
      print('❌ ChatController Error: $e');
      error.value = 'Failed to load conversations: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchConversationMessages(String userId) async {
    try {
      isLoading.value = true;
      error.value = '';
      final fetchedMessages = await _chatService.getConversationMessages(
        userId,
      );
      conversationMessages.assignAll(fetchedMessages);
    } catch (e) {
      print('❌ ChatController Conversation Error: $e');
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
      final userId = selectedUser.value?.id;
      if (userId != null) {
        fetchConversationMessages(userId);
      }
      fetchConversations();
    } catch (e) {
      print('❌ Send Message Error: $e');
      Get.snackbar('Error', 'Failed to send message');
    }
  }
}
