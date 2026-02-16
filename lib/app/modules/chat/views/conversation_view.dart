import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/chat_controller.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../../core/app_colors.dart';

class ConversationView extends GetView<ChatController> {
  const ConversationView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController messageController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final selectedUser = controller.selectedUser.value;
              final currentUserId = controller.currentUser['_id']?.toString();

              if (selectedUser == null) {
                return const Center(child: Text('No user selected'));
              }

              final messages = controller.conversationMessages;
              if (messages.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final bool isMe = message.sender.id == currentUserId;
                  return _buildChatBubble(context, message, isMe);
                },
              );
            }),
          ),

          // Input Area
          _buildInputArea(messageController),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.black87,
          size: 20,
        ),
      ),
      title: Obx(() {
        final user = controller.selectedUser.value;
        return Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl:
                          user?.avatar ??
                          'https://ui-avatars.com/api/?name=${user?.name ?? 'User'}&background=random',
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                      placeholder: (context, url) => const Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Unknown',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ],
        );
      }),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Iconsax.call, color: Colors.black87, size: 22),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Iconsax.video, color: Colors.black87, size: 22),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.message_2, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(
    BuildContext context,
    ChatMessageModel message,
    bool isMe,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onLongPress: isMe ? () => _showPopupMenu(context, message) : null,
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[200],
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: message.sender.avatar ?? '',
                    fit: BoxFit.cover,
                    width: 32,
                    height: 32,
                    placeholder: (context, url) =>
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: isMe
                          ? LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [Colors.grey[100]!, Colors.grey[200]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isMe ? 20 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isMe ? AppColors.primary : Colors.grey)
                              .withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.content,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                        if (message.isEdited) ...[
                          const SizedBox(height: 4),
                          Text(
                            '(edited)',
                            style: TextStyle(
                              color: isMe ? Colors.white70 : Colors.grey[600],
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 10),
                  ),
                ],
              ),
            ),
            if (isMe) const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  void _showPopupMenu(BuildContext context, ChatMessageModel message) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Iconsax.edit, color: Colors.blue),
              title: const Text('Edit Message'),
              onTap: () {
                Get.back();
                _showEditDialog(message);
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.trash, color: Colors.red),
              title: const Text('Delete Message'),
              onTap: () {
                Get.back();
                _showDeleteConfirmation(message);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(ChatMessageModel message) {
    final TextEditingController editController = TextEditingController(
      text: message.content,
    );
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: editController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Update your message...'),
          maxLines: null,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (editController.text.trim().isNotEmpty) {
                controller.editMessage(message.id, editController.text.trim());
                Get.back();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(ChatMessageModel message) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              controller.deleteMessage(message.id);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(TextEditingController textController) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attachment Button
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Iconsax.add, color: Colors.black54),
            ),
          ),
          const SizedBox(width: 12),
          // Text Field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Send Button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                controller.sendMessage(textController.text);
                textController.clear();
              },
              icon: const Icon(Iconsax.send_1, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
