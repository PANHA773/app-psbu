import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';
import '../../modules/chat/controllers/chat_controller.dart';
import '../models/chat_message_model.dart';
import 'auth_service.dart';
import 'chat_service.dart';

class ChatAlertService extends GetxService {
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'chat_messages',
    'Chat Messages',
    description: 'Immediate alerts for new chat messages.',
    importance: Importance.high,
  );

  final ChatService _chatService = ChatService();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  final Set<String> _seenMessageIds = <String>{};
  Timer? _pollTimer;
  bool _notificationsReady = false;
  bool _primed = false;
  String? _currentUserId;

  Future<ChatAlertService> init() async {
    await _ensureNotificationsReady();
    return this;
  }

  Future<void> start() async {
    if (_pollTimer != null) return;
    if (AuthService.token == null || AuthService.token == 'guest') return;

    await _ensureNotificationsReady();
    await _loadCurrentUser();
    await _primeSeenMessages();

    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _checkForNewMessages();
    });
  }

  Future<void> stop() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    _seenMessageIds.clear();
    _primed = false;
    _currentUserId = null;
  }

  Future<void> refreshAuthState() async {
    if (AuthService.token == null || AuthService.token == 'guest') {
      await stop();
      return;
    }
    await start();
  }

  Future<void> _ensureNotificationsReady() async {
    if (_notificationsReady) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _notifications.initialize(initSettings);

    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();
    await android?.createNotificationChannel(_channel);

    final ios = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);

    _notificationsReady = true;
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService.getCurrentUser();
    _currentUserId = user?['_id']?.toString();
  }

  Future<void> _primeSeenMessages() async {
    try {
      final messages = await _chatService.getMessages();
      _seenMessageIds.addAll(messages.map((m) => m.id));
      _primed = true;
    } catch (e) {
      debugPrint('ChatAlertService prime error: $e');
    }
  }

  Future<void> _checkForNewMessages() async {
    if (AuthService.token == null || AuthService.token == 'guest') {
      await stop();
      return;
    }

    try {
      if (_currentUserId == null) {
        await _loadCurrentUser();
      }

      final messages = await _chatService.getMessages();
      if (!_primed) {
        _seenMessageIds.addAll(messages.map((m) => m.id));
        _primed = true;
        return;
      }

      final newMessages = messages.where(
        (m) => !_seenMessageIds.contains(m.id),
      );
      final incoming =
          newMessages
              .where(
                (m) => m.sender.id.isNotEmpty && m.sender.id != _currentUserId,
              )
              .toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      for (final message in newMessages) {
        _seenMessageIds.add(message.id);
      }

      for (final message in incoming) {
        if (_isCurrentOpenConversation(message)) continue;
        await _showAlert(message);
      }
    } catch (e) {
      debugPrint('ChatAlertService poll error: $e');
    }
  }

  bool _isCurrentOpenConversation(ChatMessageModel message) {
    if (Get.currentRoute != Routes.CONVERSATION) return false;
    if (!Get.isRegistered<ChatController>()) return false;

    final selectedUser = Get.find<ChatController>().selectedUser.value;
    return selectedUser?.id == message.sender.id;
  }

  Future<void> _showAlert(ChatMessageModel message) async {
    final title = 'New message from ${message.sender.name}';
    final body = _messagePreview(message);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
    );

    final id = DateTime.now().millisecondsSinceEpoch % 2147483647;
    await _notifications.show(id, title, body, details);
  }

  String _messagePreview(ChatMessageModel message) {
    final content = message.content.trim();
    if (content.isNotEmpty && content != '[Voice message]') {
      return content;
    }
    if (message.audio != null && message.audio!.isNotEmpty) {
      return 'Sent a voice message';
    }
    return 'Sent you a new message';
  }
}
