import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/app_colors.dart';
import '../../../data/models/announcement_model.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../data/models/friend_request_model.dart';
import '../../../data/models/friend_user_model.dart';
import '../../add-friend/controllers/add_friend_controller.dart';
import '../controllers/chat_controller.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ChatController controller;
  late final AddFriendController friendController;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController announcementController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    controller = Get.isRegistered<ChatController>()
        ? Get.find<ChatController>()
        : Get.put(ChatController());
    friendController = Get.isRegistered<AddFriendController>()
        ? Get.find<AddFriendController>()
        : Get.put(AddFriendController());
    friendController.fetchAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    announcementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 6,
        leading: _iconButton(
          isDark: isDark,
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: Get.back,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [Color(0xFFFFA221), Color(0xFFFF6F3C)],
                ).createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                );
              },
              child: const Text(
                'Messages',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Obx(() {
              return Text(
                '${controller.conversations.length} chats | ${controller.announcements.length} announcements',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              );
            }),
          ],
        ),
        actions: [
          _iconButton(
            isDark: isDark,
            icon: Iconsax.refresh,
            onTap: () {
              controller.fetchConversations();
              controller.fetchAnnouncements();
              friendController.fetchAll();
            },
          ),
          const SizedBox(width: 8),
          _iconButton(
            isDark: isDark,
            icon: Iconsax.setting_2,
            onTap: () => Get.toNamed('/chat-settings'),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          _overviewCard(isDark),
          _searchBar(isDark),
          _tabBar(isDark),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _chatsTab(isDark),
                _friendsTab(isDark),
                _announcementsTab(isDark),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Iconsax.add),
        label: const Text('New', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: _showQuickActions,
      ),
    );
  }

  Widget _iconButton({
    required bool isDark,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF23242A) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _overviewCard(bool isDark) {
    return Obx(() {
      return Container(
        margin: const EdgeInsets.fromLTRB(18, 12, 18, 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF2A221A), Color(0xFF221D17)]
                : const [Color(0xFFFFF1E1), Color(0xFFFFF8EF)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF403227) : const Color(0xFFFFE0BB),
          ),
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _chip(
              '${controller.conversations.length} chats',
              Iconsax.message,
              isDark,
            ),
            _chip(
              '${friendController.receivedRequests.length} requests',
              Iconsax.user_add,
              isDark,
            ),
            _chip(
              '${friendController.friends.length} friends',
              Iconsax.people,
              isDark,
            ),
            _chip(
              '${controller.announcements.length} announcements',
              Iconsax.notification,
              isDark,
            ),
          ],
        ),
      );
    });
  }

  Widget _chip(String text, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2E261E)
            : Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey[100] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1C22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2E36) : const Color(0xFFE8EBF0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.search_normal,
            size: 18,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[100] : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Search chats, friends, or requests',
                hintStyle: TextStyle(
                  fontSize: 13.5,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (searchController.text.isNotEmpty)
            InkWell(
              borderRadius: BorderRadius.circular(99),
              onTap: () {
                searchController.clear();
                setState(() {});
              },
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2D2F37) : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 15,
                  color: isDark ? Colors.grey[200] : Colors.grey[700],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 8),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1C22) : const Color(0xFFF4F6F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[700],
        labelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFA221), Color(0xFFFF6F3C)],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        tabs: const [
          Tab(
            height: 40,
            iconMargin: EdgeInsets.only(bottom: 4),
            icon: Icon(Iconsax.message, size: 16),
            text: 'Chats',
          ),
          Tab(
            height: 40,
            iconMargin: EdgeInsets.only(bottom: 4),
            icon: Icon(Iconsax.people, size: 16),
            text: 'Friends',
          ),
          Tab(
            height: 40,
            iconMargin: EdgeInsets.only(bottom: 4),
            icon: Icon(Iconsax.notification, size: 16),
            text: 'Announcements',
          ),
        ],
      ),
    );
  }

  Widget _chatsTab(bool isDark) {
    return Obx(() {
      final filteredRecent = _filteredConversations(
        controller.recentConversations,
      ).take(10).toList();
      final filtered = _filteredConversations(controller.conversations);

      if (controller.isLoading.value && controller.conversations.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.conversations.isEmpty) {
        return _emptyState(
          'No conversations yet',
          'Start a new chat from New > Add Friend.',
        );
      }
      if (filtered.isEmpty) {
        return _emptyState('No matches', 'Try a different name or email.');
      }

      return ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 90),
        children: [
          if (filteredRecent.isNotEmpty) ...[
            _sectionTitle('Active now', '${filteredRecent.length} online'),
            SizedBox(
              height: 94,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                itemCount: filteredRecent.length,
                itemBuilder: (context, index) {
                  final user = filteredRecent[index];
                  return GestureDetector(
                    onTap: () {
                      controller.setSelectedUser(user);
                      Get.toNamed('/conversation');
                    },
                    child: SizedBox(
                      width: 70,
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFFF9F20),
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child: _avatar(
                                      _safeUrl(user.avatar),
                                      user.name,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00C07A),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark
                                            ? const Color(0xFF101217)
                                            : Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user.name.split(' ').first,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          _sectionTitle('Conversations', '${filtered.length} total'),
          ...filtered.map((user) => _conversationTile(user, isDark)),
        ],
      );
    });
  }

  Widget _conversationTile(ChatSender user, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      child: Material(
        color: isDark ? const Color(0xFF1B1C22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            controller.setSelectedUser(user);
            Get.toNamed('/conversation');
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2B2D35)
                    : const Color(0xFFE9ECF1),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: _avatar(_safeUrl(user.avatar), user.name),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.isEmpty ? 'Unknown' : user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.grey[100] : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        user.bio?.trim().isNotEmpty == true
                            ? user.bio!.trim()
                            : user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF24262E)
                        : const Color(0xFFF3F5F8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Iconsax.arrow_right_3,
                    size: 16,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _friendsTab(bool isDark) {
    return Obx(() {
      final requests = _filteredRequests(friendController.receivedRequests);
      final friends = _filteredFriends(friendController.friends);

      if (friendController.isLoading.value &&
          requests.isEmpty &&
          friends.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (requests.isEmpty && friends.isEmpty) {
        return _emptyState('No people found', 'Try a different search term.');
      }

      return ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 90),
        children: [
          _sectionTitle('Friend requests', '${requests.length} pending'),
          if (requests.isEmpty)
            _infoTile('No incoming requests right now')
          else
            ...requests.map((r) => _requestTile(r, isDark)),
          _sectionTitle('All friends', '${friends.length} connected'),
          if (friends.isEmpty)
            _infoTile('No friends match your search')
          else
            ...friends.map((f) => _friendTile(f, isDark)),
        ],
      );
    });
  }

  Widget _announcementsTab(bool isDark) {
    return Obx(() {
      if (controller.isAnnouncementsLoading.value &&
          controller.announcements.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final items = controller.announcements;

      return Column(
        children: [
          if (controller.isAdmin)
            _announcementComposer(isDark)
          else
            _infoTile('Only admins can post announcements.'),
          Expanded(
            child: items.isEmpty
                ? _emptyState(
                    'No announcements yet',
                    'Announcements from admins will appear here in real time.',
                  )
                : RefreshIndicator(
                    onRefresh: () =>
                        controller.fetchAnnouncements(showLoader: false),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 90),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) =>
                          _announcementTile(items[index], isDark),
                    ),
                  ),
          ),
        ],
      );
    });
  }

  Widget _announcementComposer(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 8, 18, 4),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1C22) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2B2D35) : const Color(0xFFE9ECF1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: announcementController,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write an announcement for everyone...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 12.5,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {
              final text = announcementController.text.trim();
              if (text.isEmpty) return;
              controller.sendAnnouncement(text);
              announcementController.clear();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(42, 38),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Icon(Iconsax.send_1, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _announcementTile(AnnouncementModel item, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1C22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2B2D35) : const Color(0xFFE9ECF1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.notification_bing,
                  color: AppColors.primary,
                  size: 15,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.sender.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.grey[100] : Colors.black87,
                  ),
                ),
              ),
              Text(
                _formatAnnouncementTime(item.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.content,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.4,
              color: isDark ? Colors.grey[200] : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestTile(FriendRequestModel request, bool isDark) {
    final user = request.requester;
    if (user == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1C22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2B2D35) : const Color(0xFFE9ECF1),
        ),
      ),
      child: Row(
        children: [
          _friendAvatar(user),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.isEmpty ? 'Unknown' : user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.grey[100] : Colors.black87,
                  ),
                ),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => friendController.acceptRequest(request.id),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(68, 34),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Accept',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => friendController.declineRequest(request.id),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2C2E36)
                    : const Color(0xFFF3F5F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.close,
                size: 18,
                color: isDark ? Colors.grey[200] : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _friendTile(FriendUser user, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      child: Material(
        color: isDark ? const Color(0xFF1B1C22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            controller.setSelectedUser(_toChatSender(user));
            Get.toNamed('/conversation');
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2B2D35)
                    : const Color(0xFFE9ECF1),
              ),
            ),
            child: Row(
              children: [
                _friendAvatar(user),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.isEmpty ? 'Unknown' : user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.grey[100] : Colors.black87,
                        ),
                      ),
                      Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    controller.setSelectedUser(_toChatSender(user));
                    Get.toNamed('/conversation');
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Iconsax.message,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _friendAvatar(FriendUser user) {
    final avatarUrl = _safeUrl(user.avatar);
    final fallback = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      backgroundImage: avatarUrl == null ? null : NetworkImage(avatarUrl),
      child: avatarUrl == null
          ? Text(
              fallback,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );
  }

  Widget _avatar(String? avatarUrl, String name) {
    final fallback = name.isNotEmpty ? name[0].toUpperCase() : '?';
    if (avatarUrl == null) {
      return Container(
        color: AppColors.primary.withValues(alpha: 0.15),
        alignment: Alignment.center,
        child: Text(
          fallback,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: avatarUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.primary.withValues(alpha: 0.15),
        alignment: Alignment.center,
        child: Text(
          fallback,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.primary.withValues(alpha: 0.15),
        alignment: Alignment.center,
        child: Text(
          fallback,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String trailing) {
    final isDark = Get.isDarkMode;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey[100] : Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            trailing,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String text) {
    final isDark = Get.isDarkMode;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B1C22) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF2B2D35) : const Color(0xFFE9ECF1),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.5,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(String title, String subtitle) {
    final isDark = Get.isDarkMode;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.message_remove,
                size: 32,
                color: AppColors.primary,
              ),
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
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickActions() {
    final isDark = Get.isDarkMode;
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF17181D) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Iconsax.user_add, color: AppColors.primary),
                ),
                title: const Text(
                  'Add Friend',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('Find and connect with a new person'),
                onTap: () {
                  Get.back();
                  Get.toNamed('/add-friend');
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Iconsax.refresh, color: Colors.blue),
                ),
                title: const Text(
                  'Refresh Data',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('Reload chats, requests, and friends'),
                onTap: () {
                  Get.back();
                  controller.fetchConversations();
                  controller.fetchAnnouncements();
                  friendController.fetchAll();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _safeUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
    return raw.trim();
  }

  String _formatAnnouncementTime(DateTime time) {
    final now = DateTime.now();
    final isToday =
        now.year == time.year && now.month == time.month && now.day == time.day;
    if (isToday) {
      final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
      final minute = time.minute.toString().padLeft(2, '0');
      final suffix = time.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $suffix';
    }
    return '${time.day}/${time.month}/${time.year}';
  }

  String get _searchQuery => searchController.text.trim().toLowerCase();

  List<ChatSender> _filteredConversations(List<ChatSender> users) {
    if (_searchQuery.isEmpty) return users;
    return users
        .where(
          (u) =>
              u.name.toLowerCase().contains(_searchQuery) ||
              u.email.toLowerCase().contains(_searchQuery),
        )
        .toList();
  }

  List<FriendUser> _filteredFriends(List<FriendUser> users) {
    if (_searchQuery.isEmpty) return users;
    return users
        .where(
          (u) =>
              u.name.toLowerCase().contains(_searchQuery) ||
              u.email.toLowerCase().contains(_searchQuery),
        )
        .toList();
  }

  List<FriendRequestModel> _filteredRequests(
    List<FriendRequestModel> requests,
  ) {
    if (_searchQuery.isEmpty) return requests;
    return requests.where((r) {
      final requester = r.requester;
      if (requester == null) return false;
      return requester.name.toLowerCase().contains(_searchQuery) ||
          requester.email.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  ChatSender _toChatSender(FriendUser user) {
    return ChatSender(
      id: user.id,
      name: user.name,
      email: user.email,
      role: 'user',
      avatar: user.avatar,
      bio: user.bio,
      gender: null,
    );
  }
}
