import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/app_colors.dart';
import '../controllers/chat_controller.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../data/models/friend_request_model.dart';
import '../../../data/models/friend_user_model.dart';
import '../../add-friend/controllers/add_friend_controller.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final controller = Get.put(ChatController());
  final friendController = Get.put(AddFriendController());
  final TextEditingController addFriendUserIdController =
      TextEditingController();
  final TextEditingController addFriendMessageController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    friendController.fetchAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    addFriendUserIdController.dispose();
    addFriendMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),

          // Tabs
          _buildTabBar(),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildChatsTab(), _buildFriendsTab()],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_rounded,
            size: 20,
            color: Colors.black87,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Messages',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          Text(
            '12 unread messages',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            // New message
            Get.toNamed('/add-friend');
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Iconsax.edit, size: 22, color: Colors.black87),
          ),
        ),
        IconButton(
          onPressed: () {
            // Settings
            Get.toNamed('/chat-settings');
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Iconsax.setting_2,
              size: 22,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.search_normal, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search messages or friends...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Iconsax.filter, size: 18, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.purple],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.message, size: 18),
                SizedBox(width: 6),
                Text('Chats'),
              ],
            ),
          ),

          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.user_add, size: 18),
                SizedBox(width: 6),
                Text('Friends'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        // Active Now Section
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 16, bottom: 12),
          child: Text(
            'Active Now',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
        ),
        Obx(
          () => SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: controller.recentConversations.length,
              itemBuilder: (context, index) {
                final user = controller.recentConversations[index];
                return _buildAvatarItem(user);
              },
            ),
          ),
        ),

        // Recent Messages
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 24, bottom: 12),
          child: Text(
            'Recent Messages',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
        ),

        // Chat List
        GetX<ChatController>(
          builder: (controller) {
            if (controller.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (controller.conversations.isEmpty) {
              return const Center(child: Text("No conversations yet"));
            }
            return Column(
              children: controller.conversations
                  .map(
                    (user) => _buildConversationItem(
                      user: user,
                      isUnread: false,
                      isPinned: false,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAvatarItem(ChatSender user) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: 60, // Constrain width
      child: GestureDetector(
        onTap: () {
          controller.setSelectedUser(user);
          Get.toNamed('/conversation');
        },
        child: Column(
          mainAxisSize: MainAxisSize.min, // Use min size
          children: [
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: CachedNetworkImage(
                      imageUrl:
                          user.avatar ??
                          'https://ui-avatars.com/api/?name=${user.name}&background=random',
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(strokeWidth: 2),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.person),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                user.name.split(' ').first,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationItem({
    required ChatSender user,
    required bool isUnread,
    required bool isPinned,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            controller.setSelectedUser(user);
            Get.toNamed('/conversation');
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.blue.withOpacity(0.1),
          highlightColor: Colors.blue.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!, width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: CachedNetworkImage(
                          imageUrl: user.avatar ?? '',
                          fit: BoxFit.cover,
                          width: 56,
                          height: 56,
                          placeholder: (context, url) => Container(
                            color: AppColors.primary.withOpacity(0.1),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.primary.withOpacity(0.1),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 28,
                            ),
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
                const SizedBox(width: 16),

                // Message Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isUnread
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isUnread
                                    ? Colors.black87
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                          if (isPinned)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Iconsax.coin,
                                size: 12,
                                color: Colors.blue,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to continue private chat',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Iconsax.clock,
                            size: 12,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '2 hours ago',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                          const Spacer(),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Unread Count
                if (isUnread)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '3',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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

  Widget _buildGroupsTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 24, bottom: 12),
          child: Text(
            'Send Friend Request',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: addFriendUserIdController,
                    decoration: const InputDecoration(
                      labelText: 'User ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addFriendMessageController,
                    decoration: const InputDecoration(
                      labelText: 'Message (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final userId = addFriendUserIdController.text.trim();
                        if (userId.isEmpty) return;
                        friendController.sendRequest(
                          userId,
                          message: addFriendMessageController.text.trim(),
                        );
                        addFriendUserIdController.clear();
                        addFriendMessageController.clear();
                      },
                      child: const Text('Send Request'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFriendsTab() {
    return Obx(() {
      if (friendController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 24, bottom: 12),
            child: Text(
              'Friend Requests (${friendController.receivedRequests.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
          ),
          if (friendController.receivedRequests.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text('No friend requests'),
            )
          else
            ...friendController.receivedRequests
                .map(_buildFriendRequestItem)
                .toList(),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 24, bottom: 12),
            child: Text(
              'All Friends (${friendController.friends.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
          ),
          if (friendController.friends.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text('No friends yet'),
            )
          else
            ...friendController.friends.map(_buildFriendItem).toList(),
        ],
      );
    });
  }

  Widget _buildFriendRequestItem(FriendRequestModel request) {
    final user = request.requester;
    if (user == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!, width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _buildFriendAvatar(user),
              const SizedBox(width: 16),

              // Friend Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.isEmpty ? 'Unknown' : user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    if (request.message.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        request.message,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Action Buttons
              Row(
                children: [
                  TextButton(
                    onPressed: () => friendController.acceptRequest(request.id),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () =>
                        friendController.declineRequest(request.id),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      padding: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendItem(FriendUser user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            controller.setSelectedUser(_toChatSender(user));
            Get.toNamed('/conversation');
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.purple.withOpacity(0.1),
          highlightColor: Colors.purple.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!, width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildFriendAvatar(user),
                const SizedBox(width: 16),

                // Friend Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.isEmpty ? 'Unknown' : user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Iconsax.message,
                        size: 18,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Iconsax.more,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFriendAvatar(FriendUser user) {
    final initials = user.name.isNotEmpty ? user.name[0] : '?';
    if (user.avatar == null || user.avatar!.isEmpty) {
      return CircleAvatar(child: Text(initials));
    }
    return CircleAvatar(backgroundImage: NetworkImage(user.avatar!));
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

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // New chat or add friend
        Get.bottomSheet(
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Iconsax.message_add, color: Colors.blue),
                  ),
                  title: const Text('New Message'),
                  onTap: () {
                    Get.back();
                    Get.toNamed('/new-message');
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Iconsax.user_add, color: Colors.green),
                  ),
                  title: const Text('Add Friend'),
                  onTap: () {
                    Get.back();
                    Get.toNamed('/add-friend');
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Iconsax.people, color: Colors.purple),
                  ),
                  title: const Text('Create Group'),
                  onTap: () {
                    Get.back();
                    Get.toNamed('/create-group');
                  },
                ),
              ],
            ),
          ),
        );
      },
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Iconsax.add, size: 24),
    );
  }
}
