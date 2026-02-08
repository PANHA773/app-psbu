import 'friend_user_model.dart';

class FriendRequestModel {
  final String id;
  final String status;
  final String message;
  final FriendUser? requester;
  final FriendUser? recipient;

  FriendRequestModel({
    required this.id,
    required this.status,
    required this.message,
    this.requester,
    this.recipient,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['_id']?.toString() ?? '',
      status: json['status'] ?? 'pending',
      message: json['message'] ?? '',
      requester: json['requester'] is Map<String, dynamic>
          ? FriendUser.fromJson(json['requester'])
          : null,
      recipient: json['recipient'] is Map<String, dynamic>
          ? FriendUser.fromJson(json['recipient'])
          : null,
    );
  }
}
