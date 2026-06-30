import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BrainDumpService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveAnalysis({
    required String rawText,
    required Map<String, dynamic> analysis,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final userRef = _db.collection('users').doc(user.uid);

    final tasks = List<Map<String, dynamic>>.from(analysis['tasks'] ?? []);
    final dailyPlan =
        List<Map<String, dynamic>>.from(analysis['dailyPlan'] ?? []);

    final dumpRef = await userRef.collection('brain_dumps').add({
      'rawText': rawText.trim(),
      'summary': analysis['summary'] ?? '',
      'riskLevel': analysis['riskLevel'] ?? 'low',
      'recommendation': analysis['recommendation'] ?? '',
      'taskCount': tasks.length,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await userRef.collection('daily_plans').add({
      'dumpId': dumpRef.id,
      'date': DateTime.now().toIso8601String().substring(0, 10),
      'items': dailyPlan,
      'createdAt': FieldValue.serverTimestamp(),
    });

    for (final task in tasks) {
      await userRef.collection('tasks').add({
        'dumpId': dumpRef.id,
        'title': task['title'] ?? '',
        'category': task['category'] ?? 'other',
        'priority': task['priority'] ?? 'medium',
        'estimatedMinutes': task['estimatedMinutes'] ?? 30,
        'deadline': task['deadline'],
        'reason': task['reason'] ?? '',
        'urgencyScore': task['urgencyScore'] ?? 1,
        'importanceScore': task['importanceScore'] ?? 1,
        'energyLevel': task['energyLevel'] ?? 'medium',
        'canSplit': task['canSplit'] ?? false,
        'project': task['project'],
        'tags': task['tags'] ?? [],
        'completed': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}