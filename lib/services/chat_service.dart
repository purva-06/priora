import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat_message_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DocumentReference<Map<String, dynamic>>? get _chatRef {
    final user = _auth.currentUser;
    if (user == null) return null;

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('chat_conversations')
        .doc('main');
  }

  Future<void> ensureMainConversation() async {
    final ref = _chatRef;
    if (ref == null) return;

    await ref.set({
      'title': 'Priora Assistant',
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<ChatMessageModel>> getMessages() {
    final ref = _chatRef;
    if (ref == null) return Stream.value([]);

    return ref
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => ChatMessageModel.fromDoc(doc)).toList(),
        );
  }

  Future<void> addUserMessage(String text) async {
    final ref = _chatRef;
    if (ref == null) return;

    await ensureMainConversation();

    await ref.collection('messages').add({
      'role': 'user',
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    await ref.update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> addAssistantMessage({
    required String text,
    required Map<String, dynamic> proposedPlan,
  }) async {
    final ref = _chatRef;
    if (ref == null) return null;

    await ensureMainConversation();

    final doc = await ref.collection('messages').add({
      'role': 'assistant',
      'text': text.trim(),
      'proposedPlan': proposedPlan,
      'applied': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await ref.update({
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<void> markApplied(String messageId) async {
    final ref = _chatRef;
    if (ref == null) return;

    await ref.collection('messages').doc(messageId).update({
      'applied': true,
      'appliedAt': FieldValue.serverTimestamp(),
    });
  }
}