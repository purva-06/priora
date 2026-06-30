import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String dumpId;
  final String title;
  final String category;
  final String priority;
  final int estimatedMinutes;
  final String? deadline;
  final String reason;
  final int urgencyScore;
  final int importanceScore;
  final String energyLevel;
  final bool canSplit;
  final String? project;
  final List<String> tags;
  final bool completed;

  TaskModel({
    required this.id,
    required this.dumpId,
    required this.title,
    required this.category,
    required this.priority,
    required this.estimatedMinutes,
    required this.deadline,
    required this.reason,
    required this.urgencyScore,
    required this.importanceScore,
    required this.energyLevel,
    required this.canSplit,
    required this.project,
    required this.tags,
    required this.completed,
  });

  factory TaskModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TaskModel(
      id: doc.id,
      dumpId: data['dumpId'] ?? '',
      title: data['title'] ?? '',
      category: data['category'] ?? 'other',
      priority: data['priority'] ?? 'medium',
      estimatedMinutes: data['estimatedMinutes'] ?? 30,
      deadline: data['deadline'],
      reason: data['reason'] ?? '',
      urgencyScore: data['urgencyScore'] ?? 1,
      importanceScore: data['importanceScore'] ?? 1,
      energyLevel: data['energyLevel'] ?? 'medium',
      canSplit: data['canSplit'] ?? false,
      project: data['project'],
      tags: List<String>.from(data['tags'] ?? []),
      completed: data['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': id,
      'dumpId': dumpId,
      'title': title,
      'category': category,
      'priority': priority,
      'estimatedMinutes': estimatedMinutes,
      'deadline': deadline,
      'reason': reason,
      'urgencyScore': urgencyScore,
      'importanceScore': importanceScore,
      'energyLevel': energyLevel,
      'canSplit': canSplit,
      'project': project,
      'tags': tags,
      'completed': completed,
    };
  }
}