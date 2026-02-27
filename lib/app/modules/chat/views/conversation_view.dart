import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/app_colors.dart';
import '../../../data/models/chat_message_model.dart';
import '../controllers/chat_controller.dart';
import 'widgets/audio_message_bubble.dart';

class ConversationView extends StatefulWidget {
  const ConversationView({super.key});

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  final ChatController controller = Get.find<ChatController>();
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  late final Worker _messageWorker;

  @override
  void initState() {
    super.initState();
    final selectedUser = controller.selectedUser.value;
    if (selectedUser != null) {
      controller.startRealtimeUpdates(selectedUser.id);
    }
    _messageFocusNode.addListener(() {
      if (_messageFocusNode.hasFocus) {
        _scrollToBottom(animated: true);
      }
    });
    _messageWorker = ever(controller.conversationMessages, (_) {
      _scrollToBottom(animated: true);
    });
  }

  @override
  void dispose() {
    controller.stopRealtimeUpdates();
    _messageWorker.dispose();
    _messageFocusNode.dispose();
    _scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? const [Color(0xFF121317), Color(0xFF16181D)]
                      : const [Color(0xFFF8FAFD), Color(0xFFF0F4F9)],
                ),
              ),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final selectedUser = controller.selectedUser.value;
                final currentUserId = controller.currentUser['_id']?.toString();

                if (selectedUser == null) {
                  return _buildEmptyState(
                    icon: Iconsax.user_remove,
                    title: 'No user selected',
                    subtitle: 'Return and pick a conversation.',
                  );
                }

                final messages = controller.conversationMessages;
                if (messages.isEmpty) {
                  return _buildEmptyState(
                    icon: Iconsax.message_text_1,
                    title: 'No messages yet',
                    subtitle:
                        'Send the first message to start this conversation.',
                  );
                }

                return ListView.separated(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
                  itemCount: messages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.sender.id == currentUserId;
                    return _buildChatBubble(context, message, isMe, isDark);
                  },
                );
              }),
            ),
          ),
          _buildTypingIndicator(isDark),
          _buildInputArea(isDark),
        ],
      ),
    );
  }

  AppBar _buildAppBar(bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF121317) : Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: _actionIcon(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: Get.back,
          isDark: isDark,
        ),
      ),
      titleSpacing: 8,
      title: Obx(() {
        final user = controller.selectedUser.value;
        final avatarUrl = _safeAvatarUrl(user?.avatar);
        final showTyping = controller.isOtherUserTyping.value;
        final isOnline =
            showTyping || controller.conversationMessages.isNotEmpty;

        return Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 1.6,
                ),
              ),
              child: CircleAvatar(
                radius: 19,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(19),
                  child: _buildAvatarContent(
                    avatarUrl: avatarUrl,
                    name: user?.name ?? 'User',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Unknown',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isOnline
                              ? const Color(0xFF00C07A)
                              : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        showTyping
                            ? 'Typing...'
                            : (isOnline ? 'Online' : 'Offline'),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: showTyping
                              ? AppColors.primary
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      actions: [
        _actionIcon(
          icon: Iconsax.call,
          isDark: isDark,
          onTap: () {
            final user = controller.selectedUser.value;
            if (user == null) return;
            Get.toNamed(
              '/call',
              arguments: {
                'userId': user.id,
                'userName': user.name,
                'userAvatar': _safeAvatarUrl(user.avatar),
                'channelName': 'chat_${user.id}',
                'videoCall': false,
              },
            );
          },
        ),
        const SizedBox(width: 8),
        _actionIcon(
          icon: Iconsax.video,
          isDark: isDark,
          onTap: () {
            final user = controller.selectedUser.value;
            if (user == null) return;
            Get.toNamed(
              '/video-call',
              arguments: {
                'userId': user.id,
                'userName': user.name,
                'userAvatar': _safeAvatarUrl(user.avatar),
                'channelName': 'chat_${user.id}',
                'videoCall': true,
              },
            );
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _actionIcon({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF202228) : const Color(0xFFF3F5F8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? Colors.grey[100] : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildAvatarContent({
    required String? avatarUrl,
    required String name,
  }) {
    final fallback = name.isNotEmpty ? name[0].toUpperCase() : '?';

    if (avatarUrl == null) {
      return Center(
        child: Text(
          fallback,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: avatarUrl,
      fit: BoxFit.cover,
      width: 38,
      height: 38,
      placeholder: (context, url) => Center(
        child: Text(
          fallback,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Center(
        child: Text(
          fallback,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isDark = Get.isDarkMode;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: AppColors.primary),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(
    BuildContext context,
    ChatMessageModel message,
    bool isMe,
    bool isDark,
  ) {
    final hasText = message.content.trim().isNotEmpty;
    final hasAudio = message.audio != null && message.audio!.isNotEmpty;

    return GestureDetector(
      onLongPress: isMe ? () => _showPopupMenu(context, message, isDark) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 15,
              backgroundColor: isDark
                  ? const Color(0xFF2A2D34)
                  : Colors.grey[200],
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _buildAvatarContent(
                  avatarUrl: _safeAvatarUrl(message.sender.avatar),
                  name: message.sender.name,
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
                  constraints: const BoxConstraints(maxWidth: 295),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: isMe
                        ? LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.82),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isMe
                        ? null
                        : (isDark ? const Color(0xFF22252D) : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    border: Border.all(
                      color: isMe
                          ? Colors.transparent
                          : (isDark
                                ? const Color(0xFF2F323B)
                                : const Color(0xFFE5E9F0)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isMe ? 0.22 : 0.05,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasText)
                        Text(
                          message.content,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: isMe
                                ? Colors.white
                                : (isDark ? Colors.grey[100] : Colors.black87),
                          ),
                        ),
                      if (hasAudio) ...[
                        if (hasText) const SizedBox(height: 8),
                        AudioMessageBubble(
                          audioUrl: message.audio!,
                          isMe: isMe,
                          createdAt: message.createdAt,
                        ),
                      ],
                      if (message.isEdited) ...[
                        const SizedBox(height: 4),
                        Text(
                          'edited',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontStyle: FontStyle.italic,
                            color: isMe ? Colors.white70 : Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 2),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Obx(() {
      final showTyping =
          controller.isTypingInConversation.value ||
          controller.isOtherUserTyping.value;

      if (!showTyping) {
        return const SizedBox.shrink();
      }

      final text = controller.isOtherUserTyping.value
          ? '${controller.selectedUser.value?.name ?? 'Someone'} is typing...'
          : 'You are typing...';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 11.5,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }

  void _showPopupMenu(
    BuildContext context,
    ChatMessageModel message,
    bool isDark,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1C22) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(99),
              ),
            ),
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
          ],
        ),
      ),
    );
  }

  void _showEditDialog(ChatMessageModel message) {
    final editController = TextEditingController(text: message.content);
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
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
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
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              controller.deleteMessage(message.id);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Obx(() {
      final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
      final recordingMode =
          controller.isRecording.value ||
          controller.pendingRecordingPath.value.isNotEmpty;

      return AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.fromLTRB(12, 8, 12, keyboardVisible ? 8 : 16),
        child: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF181A20) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2A2D35)
                    : const Color(0xFFE6EAF0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: recordingMode
                ? _buildRecordingUI(isDark)
                : Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF252830)
                              : const Color(0xFFF4F6F9),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          Iconsax.add,
                          color: isDark ? Colors.grey[100] : Colors.grey[700],
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF23262E)
                                : const Color(0xFFF4F6F9),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            focusNode: _messageFocusNode,
                            controller: messageController,
                            onChanged: controller.onDraftChanged,
                            onTap: () => _scrollToBottom(animated: true),
                            onSubmitted: (_) => _sendTextMessage(),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.grey[100] : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Type a message',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[500],
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (messageController.text.trim().isEmpty)
                        _buildMicrophoneButton(isDark)
                      else
                        InkWell(
                          onTap: _sendTextMessage,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFA221), Color(0xFFFF6F3C)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Iconsax.send_1,
                              color: Colors.white,
                              size: 17,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      );
    });
  }

  void _sendTextMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    controller.sendMessage(text);
    messageController.clear();
    controller.onDraftChanged('');
    _scrollToBottom(animated: true);
  }

  Widget _buildMicrophoneButton(bool isDark) {
    return InkWell(
      onTap: controller.startRecording,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Iconsax.microphone_2,
          color: AppColors.primary,
          size: 19,
        ),
      ),
    );
  }

  Widget _buildRecordingUI(bool isDark) {
    final isRecording = controller.isRecording.value;
    final duration = isRecording
        ? controller.recordingDuration.value
        : controller.pendingRecordingDuration.value;
    final mins = (duration ~/ 60).toString().padLeft(2, '0');
    final secs = (duration % 60).toString().padLeft(2, '0');

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isRecording ? Icons.fiber_manual_record : Iconsax.microphone_2,
            color: isRecording ? Colors.red : AppColors.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$mins:$secs',
          style: TextStyle(
            color: isDark ? Colors.grey[100] : Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            isRecording ? 'Recording voice...' : 'Voice message ready',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        if (isRecording)
          TextButton(
            onPressed: controller.stopRecording,
            child: const Text('Stop'),
          ),
        TextButton(
          onPressed: controller.cancelRecording,
          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
        ),
        if (!isRecording)
          TextButton(
            onPressed: controller.sendPendingRecording,
            child: const Text('Send'),
          ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  String? _safeAvatarUrl(String? raw) {
    if (raw == null) return null;
    final value = raw.trim();
    if (value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
    return value;
  }
}
