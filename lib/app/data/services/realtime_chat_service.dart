import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Provides a lightweight Firestore-backed event bus for new chat data.
class RealtimeChatService {
  RealtimeChatService({FirebaseFirestore? firestore})
      : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  /// Builds a canonical conversation ID so both users listen on the same path.
  String conversationId(String userId, String otherUserId) {
    final ids = [userId, otherUserId]..sort();
    return ids.join('_');
  }

  /// Watches the latest event for the provided conversation.
  Stream<RealtimeConversationEvent?> watchConversationEvents(
    String conversationId,
  ) {
    final firestore = _resolveFirestore();
    if (firestore == null) {
      return Stream<RealtimeConversationEvent?>.value(null);
    }

    final events = firestore
        .collection('chat_conversation_events')
        .doc(conversationId)
        .collection('events')
        .orderBy('timestamp', descending: true)
        .limit(1);

    return events.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      final data = doc.data();
      return RealtimeConversationEvent(
        id: doc.id,
        action: data['action'] as String? ?? 'message',
        payload: _normalizePayload(data['payload']),
      );
    });
  }

  /// Publishes an event to wake everyone listening on the conversation.
  Future<void> publishConversationEvent({
    required String conversationId,
    required String action,
    Map<String, dynamic>? payload,
  }) async {
    final firestore = _resolveFirestore();
    if (firestore == null) return;

    final collection = firestore
        .collection('chat_conversation_events')
        .doc(conversationId)
        .collection('events');

    await collection.add({
      'action': action,
      'payload': payload ?? <String, dynamic>{},
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  FirebaseFirestore? _resolveFirestore() {
    if (_firestore != null) return _firestore;
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  Map<String, dynamic> _normalizePayload(dynamic payload) {
    if (payload is Map<String, dynamic>) return payload;
    if (payload is Map) return Map<String, dynamic>.from(payload);
    return <String, dynamic>{};
  }
}

class RealtimeConversationEvent {
  RealtimeConversationEvent({
    required this.id,
    required this.action,
    required this.payload,
  });

  final String id;
  final String action;
  final Map<String, dynamic> payload;
}
