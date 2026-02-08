import 'package:dio/dio.dart';
import '../models/friend_request_model.dart';
import '../models/friend_user_model.dart';
import 'dio_client.dart';

class UserService {
  final Dio _dio = DioClient.dio;

  Future<List<FriendUser>> getFriends() async {
    try {
      final response = await _dio.get('/users/me/friends');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => FriendUser.fromJson(json)).toList();
      }
      throw Exception('Failed to load friends');
    } catch (e) {
      print('❌ UserService getFriends Error: $e');
      rethrow;
    }
  }

  Future<List<FriendRequestModel>> getReceivedRequests() async {
    try {
      final response = await _dio.get('/users/me/friend-requests');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => FriendRequestModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load friend requests');
    } catch (e) {
      print('❌ UserService getReceivedRequests Error: $e');
      rethrow;
    }
  }

  Future<List<FriendRequestModel>> getSentRequests() async {
    try {
      final response = await _dio.get('/users/me/friend-requests/sent');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => FriendRequestModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load sent requests');
    } catch (e) {
      print('❌ UserService getSentRequests Error: $e');
      rethrow;
    }
  }

  Future<List<FriendUser>> getAllUsersForAddFriend() async {
    try {
      final response = await _dio.get('/add-friend');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => FriendUser.fromJson(json)).toList();
      }
      throw Exception('Failed to load users');
    } catch (e) {
      print('❌ UserService getAllUsersForAddFriend Error: $e');
      rethrow;
    }
  }

  Future<void> sendFriendRequest(String userId, {String? message}) async {
    try {
      await _dio.post(
        '/users/$userId/request',
        data: {'message': message ?? ''},
      );
    } catch (e) {
      print('❌ UserService sendFriendRequest Error: $e');
      rethrow;
    }
  }

  Future<void> acceptRequest(String requestId) async {
    try {
      await _dio.post('/users/friend-requests/$requestId/accept');
    } catch (e) {
      print('❌ UserService acceptRequest Error: $e');
      rethrow;
    }
  }

  Future<void> declineRequest(String requestId) async {
    try {
      await _dio.post('/users/friend-requests/$requestId/decline');
    } catch (e) {
      print('❌ UserService declineRequest Error: $e');
      rethrow;
    }
  }

  Future<void> addFriend(String userId) async {
    try {
      await _dio.post('/users/$userId/add-friend');
    } catch (e) {
      print('❌ UserService addFriend Error: $e');
      rethrow;
    }
  }

  Future<void> removeFriend(String userId) async {
    try {
      await _dio.delete('/users/$userId/remove-friend');
    } catch (e) {
      print('❌ UserService removeFriend Error: $e');
      rethrow;
    }
  }
}
