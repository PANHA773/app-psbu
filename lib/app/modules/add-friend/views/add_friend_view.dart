import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    userIdController.dispose();
    messageController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Add Friends'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: controller.fetchAll,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (controller.error.value.isNotEmpty)
              _buildErrorBanner(controller.error.value),
          
            const SizedBox(height: 16),
            _buildSectionTitle('Received Requests'),
            _buildRequestsList(controller.receivedRequests, isReceived: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Sent Requests'),
            _buildRequestsList(controller.sentRequests, isReceived: false),
            const SizedBox(height: 16),
            _buildSectionTitle('Your Friends'),
            _buildFriendsList(controller.friends),
            const SizedBox(height: 16),
            _buildSectionTitle('All Users'),
            _buildSearchField(),
            const SizedBox(height: 8),
            _buildAllUsersList(_filteredUsers()),
          ],
        );
      }),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildRequestsList(
    List<FriendRequestModel> requests, {
    required bool isReceived,
  }) {
    if (requests.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('No requests'),
      );
    }
    return Column(
      children: requests.map((request) {
        final user = isReceived ? request.requester : request.recipient;
        if (user == null) return const SizedBox.shrink();
        return _buildRequestItem(user, request, isReceived: isReceived);
      }).toList(),
    );
  }

  Widget _buildFriendsList(List<FriendUser> friends) {
    if (friends.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('No friends yet'),
      );
    }
    return Column(
      children: friends.map(_buildFriendItem).toList(),
    );
  }

  Widget _buildAllUsersList(List<FriendUser> users) {
    if (users.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('No users found'),
      );
    }
    return Column(
      children: users.map(_buildAllUserItem).toList(),
    );
  }

  Widget _buildAllUserItem(FriendUser user) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: _buildAvatar(user),
        title: Text(user.name.isEmpty ? 'Unknown' : user.name),
        trailing: TextButton(
          onPressed: () => controller.sendRequest(user.id),
          child: const Text('Add'),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search users by name',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchController.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.clear),
              ),
        border: const OutlineInputBorder(),
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

  Widget _buildRequestItem(
    FriendUser user,
    FriendRequestModel request, {
    required bool isReceived,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: _buildAvatar(user),
        title: Text(user.name.isEmpty ? 'Unknown' : user.name),
        subtitle: request.message.isNotEmpty
            ? Text(
                request.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: isReceived
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => controller.acceptRequest(request.id),
                    child: const Text('Accept'),
                  ),
                  TextButton(
                    onPressed: () => controller.declineRequest(request.id),
                    child: const Text('Decline'),
                  ),
                ],
              )
            : Text(
                request.status,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
      ),
    );
  }

  Widget _buildFriendItem(FriendUser user) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: _buildAvatar(user),
        title: Text(user.name.isEmpty ? 'Unknown' : user.name),
        subtitle: null,
        trailing: TextButton(
          onPressed: () => controller.removeFriend(user.id),
          child: const Text('Remove'),
        ),
      ),
    );
  }

  Widget _buildAvatar(FriendUser user) {
    final initials = user.name.isNotEmpty ? user.name[0] : '?';
    if (user.avatar == null || user.avatar!.isEmpty) {
      return CircleAvatar(child: Text(initials));
    }
    return CircleAvatar(backgroundImage: NetworkImage(user.avatar!));
  }
}
