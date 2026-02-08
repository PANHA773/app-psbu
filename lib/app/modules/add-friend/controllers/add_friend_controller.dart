import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../data/models/friend_request_model.dart';
import '../../../data/models/friend_user_model.dart';
import '../../../data/services/user_service.dart';

class AddFriendController extends GetxController {
  final UserService _userService = UserService();

  final RxList<FriendUser> friends = <FriendUser>[].obs;
  final RxList<FriendRequestModel> receivedRequests =
      <FriendRequestModel>[].obs;
  final RxList<FriendRequestModel> sentRequests =
      <FriendRequestModel>[].obs;
  final RxList<FriendUser> allUsers = <FriendUser>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    try {
      isLoading.value = true;
      error.value = '';
      final results = await Future.wait([
        _userService.getFriends(),
        _userService.getReceivedRequests(),
        _userService.getSentRequests(),
        _userService.getAllUsersForAddFriend(),
      ]);
      friends.assignAll(results[0] as List<FriendUser>);
      receivedRequests.assignAll(results[1] as List<FriendRequestModel>);
      sentRequests.assignAll(results[2] as List<FriendRequestModel>);
      allUsers.assignAll(results[3] as List<FriendUser>);
    } catch (e) {
      error.value = 'Failed to load data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendRequest(String userId, {String? message}) async {
    if (userId.trim().isEmpty) return;
    try {
      await _userService.sendFriendRequest(userId.trim(), message: message);
      await fetchSentRequests();
      Get.snackbar('Success', 'Friend request sent');
    } catch (e) {
      Get.snackbar('Error', _friendlyError(e, fallback: 'Failed to send request'));
    }
  }

  Future<void> acceptRequest(String requestId) async {
    try {
      await _userService.acceptRequest(requestId);
      await fetchAll();
      Get.snackbar('Success', 'Friend request accepted');
    } catch (e) {
      Get.snackbar(
        'Error',
        _friendlyError(e, fallback: 'Failed to accept request'),
      );
    }
  }

  Future<void> declineRequest(String requestId) async {
    try {
      await _userService.declineRequest(requestId);
      await fetchReceivedRequests();
      Get.snackbar('Success', 'Friend request declined');
    } catch (e) {
      Get.snackbar(
        'Error',
        _friendlyError(e, fallback: 'Failed to decline request'),
      );
    }
  }

  Future<void> removeFriend(String userId) async {
    try {
      await _userService.removeFriend(userId);
      await fetchFriends();
      Get.snackbar('Success', 'Friend removed');
    } catch (e) {
      Get.snackbar('Error', _friendlyError(e, fallback: 'Failed to remove friend'));
    }
  }

  Future<void> addFriend(String userId) async {
    if (userId.trim().isEmpty) return;
    try {
      await _userService.addFriend(userId.trim());
      await fetchFriends();
      Get.snackbar('Success', 'Friend added');
    } catch (e) {
      Get.snackbar('Error', _friendlyError(e, fallback: 'Failed to add friend'));
    }
  }

  Future<void> fetchFriends() async {
    try {
      final data = await _userService.getFriends();
      friends.assignAll(data);
    } catch (e) {
      error.value = 'Failed to load friends: $e';
    }
  }

  Future<void> fetchReceivedRequests() async {
    try {
      final data = await _userService.getReceivedRequests();
      receivedRequests.assignAll(data);
    } catch (e) {
      error.value = 'Failed to load requests: $e';
    }
  }

  Future<void> fetchSentRequests() async {
    try {
      final data = await _userService.getSentRequests();
      sentRequests.assignAll(data);
    } catch (e) {
      error.value = 'Failed to load sent requests: $e';
    }
  }

  Future<void> fetchAllUsers() async {
    try {
      final data = await _userService.getAllUsersForAddFriend();
      allUsers.assignAll(data);
    } catch (e) {
      error.value = 'Failed to load users: $e';
    }
  }

  String _friendlyError(Object error, {required String fallback}) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
      if (data is String && data.isNotEmpty) {
        return data;
      }
      if (error.response?.statusCode != null) {
        return '$fallback (HTTP ${error.response?.statusCode})';
      }
    }
    return fallback;
  }
}
