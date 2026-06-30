import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String role; // user | assistant
  final String text;
  final Map<String, dynamic>? proposedPlan;
  final bool applied;
  final Timestamp? createdAt;

  ChatMessageModel({
    required this.id,
    required this.role,
    required this.text,
    required this.proposedPlan,
    required this.applied,
    required this.createdAt,
  });

  factory ChatMessageModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatMessageModel(
      id: doc.id,
      role: data['role'] ?? 'assistant',
      text: data['text'] ?? '',
      proposedPlan: data['proposedPlan'],
      applied: data['applied'] ?? false,
      createdAt: data['createdAt'],
    );
  }
}