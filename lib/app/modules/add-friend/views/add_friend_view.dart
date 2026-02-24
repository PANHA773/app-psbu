import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/app_colors.dart';
import '../../../data/models/friend_request_model.dart';
import '../../../data/models/friend_user_model.dart';
import '../controllers/add_friend_controller.dart';

class AddFriendView extends StatefulWidget {
  const AddFriendView({super.key});

  @override
  State<AddFriendView> createState() => _AddFriendViewState();
}

class _AddFriendViewState extends State<AddFriendView> {
  final AddFriendController controller = Get.find<AddFriendController>();
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                onPressed: Get.back,
                icon: _buildTopAction(
                  icon: Iconsax.arrow_left_2,
                  isDark: isDark,
                ),
              )
            : null,
        titleSpacing: canPop ? 6 : 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [Color(0xFFFF8A00), Color(0xFFFF5A3C)],
                ).createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                );
              },
              child: const Text(
                'Friends Hub',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Text(
              'Manage requests and connections',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: controller.fetchAll,
            icon: _buildTopAction(icon: Iconsax.refresh, isDark: isDark),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _LoadingState();
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAll,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    children: [
                      _buildSummaryCard(isDark),
                      if (controller.error.value.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildErrorBanner(controller.error.value, isDark),
                      ],
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  child: _buildSearchField(isDark),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildSection(
                  title: 'Received Requests',
                  icon: Iconsax.receive_square,
                  child: _buildRequestsList(
                    controller.receivedRequests,
                    isReceived: true,
                    isDark: isDark,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildSection(
                  title: 'Sent Requests',
                  icon: Iconsax.send_sqaure_2,
                  child: _buildRequestsList(
                    controller.sentRequests,
                    isReceived: false,
                    isDark: isDark,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildSection(
                  title: 'Your Friends',
                  icon: Iconsax.people,
                  child: _buildFriendsList(controller.friends, isDark: isDark),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildSection(
                  title: 'Discover People',
                  icon: Iconsax.user_add,
                  child: _buildAllUsersList(_filteredUsers(), isDark: isDark),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTopAction({required IconData icon, required bool isDark}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF24262D) : const Color(0xFFF1F2F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 18,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildSummaryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF2B1D16), Color(0xFF1F1A18)]
              : const [Color(0xFFFFEFE2), Color(0xFFFFF7F0)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF3D302B) : const Color(0xFFFFDFC6),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8A00), Color(0xFFFF5A3C)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Iconsax.people, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _statPill(
                    '${controller.receivedRequests.length} received',
                    isDark,
                  ),
                  _statPill('${controller.sentRequests.length} sent', isDark),
                  _statPill('${controller.friends.length} friends', isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statPill(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A302B) : const Color(0xFFFFE4CF),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFFFFC696) : const Color(0xFFBA5A00),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final isDark = Get.isDarkMode;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2B1D22) : const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF4D2D37) : const Color(0xFFFFD2D2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.warning_2, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isDark ? Colors.red[200] : Colors.red[700],
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(bool isDark) {
    return TextField(
      controller: searchController,
      onChanged: (_) => setState(() {}),
      style: TextStyle(
        color: isDark ? Colors.grey[200] : Colors.black87,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: 'Search users by name',
        hintStyle: TextStyle(
          color: isDark ? Colors.grey[500] : Colors.grey[500],
          fontSize: 13.5,
        ),
        prefixIcon: const Icon(Iconsax.search_normal, size: 18),
        suffixIcon: searchController.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Iconsax.close_circle, size: 17),
              ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1D1F26) : const Color(0xFFF4F5F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  List<FriendUser> _filteredUsers() {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) return controller.allUsers;
    return controller.allUsers
        .where((user) => user.name.toLowerCase().contains(query))
        .toList();
  }

  Widget _buildRequestsList(
    List<FriendRequestModel> requests, {
    required bool isReceived,
    required bool isDark,
  }) {
    if (requests.isEmpty) {
      return _buildEmptyTile(
        isDark,
        isReceived ? 'No received requests' : 'No sent requests',
      );
    }

    return Column(
      children: requests.map((request) {
        final user = isReceived ? request.requester : request.recipient;
        if (user == null) return const SizedBox.shrink();

        return _buildListCard(
          isDark: isDark,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: _buildAvatar(user, isDark: isDark),
            title: Text(
              user.name.isEmpty ? 'Unknown' : user.name,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: request.message.isNotEmpty
                ? Text(
                    request.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  )
                : null,
            trailing: isReceived
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _miniAction(
                        label: 'Accept',
                        color: const Color(0xFF00A86B),
                        onTap: () => controller.acceptRequest(request.id),
                      ),
                      const SizedBox(width: 8),
                      _miniAction(
                        label: 'Decline',
                        color: Colors.grey,
                        onTap: () => controller.declineRequest(request.id),
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF252730)
                          : const Color(0xFFF3F4F7),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      request.status,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFriendsList(List<FriendUser> friends, {required bool isDark}) {
    if (friends.isEmpty) {
      return _buildEmptyTile(isDark, 'No friends yet');
    }

    return Column(
      children: friends.map((user) {
        return _buildListCard(
          isDark: isDark,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: _buildAvatar(user, isDark: isDark),
            title: Text(
              user.name.isEmpty ? 'Unknown' : user.name,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: _miniAction(
              label: 'Remove',
              color: Colors.redAccent,
              onTap: () => controller.removeFriend(user.id),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAllUsersList(List<FriendUser> users, {required bool isDark}) {
    if (users.isEmpty) {
      return _buildEmptyTile(isDark, 'No users found');
    }

    return Column(
      children: users.map((user) {
        return _buildListCard(
          isDark: isDark,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: _buildAvatar(user, isDark: isDark),
            title: Text(
              user.name.isEmpty ? 'Unknown' : user.name,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: _miniAction(
              label: 'Add',
              color: AppColors.primary,
              onTap: () => controller.sendRequest(user.id),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildListCard({required Widget child, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1D24) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2B2D36) : const Color(0xFFE8EBF1),
        ),
      ),
      child: child,
    );
  }

  Widget _buildEmptyTile(bool isDark, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1D24) : const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2B2D36) : const Color(0xFFE8EBF1),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _miniAction({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(FriendUser user, {required bool isDark}) {
    final initials = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
    final avatarUrl = _safeUrl(user.avatar);

    if (avatarUrl == null) {
      return CircleAvatar(
        backgroundColor: isDark
            ? const Color(0xFF2B2D36)
            : const Color(0xFFF0F2F5),
        child: Text(
          initials,
          style: TextStyle(
            color: isDark ? Colors.grey[200] : Colors.grey[700],
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return CircleAvatar(backgroundImage: NetworkImage(avatarUrl));
  }

  String? _safeUrl(String? raw) {
    if (raw == null) return null;
    final value = raw.trim();
    if (value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
    return value;
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 8,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      itemBuilder: (_, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
          ),
        );
      },
    );
  }
}
