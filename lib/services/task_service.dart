import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<TaskModel>> getTasks() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromDoc(doc)).toList(),
        );
  }

  Future<List<TaskModel>> getTasksOnce() async {
    final user = _auth.currentUser;

    if (user == null) {
      return [];
    }

    final snapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => TaskModel.fromDoc(doc)).toList();
  }

  Future<void> toggleTaskCompletion(String taskId, bool completed) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .doc(taskId)
        .update({
      'completed': completed,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTaskDuration({
    required String taskId,
    required int estimatedMinutes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .doc(taskId)
        .update({
      'estimatedMinutes': estimatedMinutes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> applyScheduleChanges(
    List<Map<String, dynamic>> updatedTasks,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _db.batch();

    for (final task in updatedTasks) {
      final taskId = task['taskId'];
      final estimatedMinutes = task['estimatedMinutes'];

      if (taskId == null || estimatedMinutes == null) continue;

      final taskRef = _db
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(taskId);

      batch.update(taskRef, {
        'estimatedMinutes': estimatedMinutes,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
}