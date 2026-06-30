import 'package:flutter/material.dart';

import '../../models/task_model.dart';
import '../../services/task_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SafeArea(
        child: StreamBuilder<List<TaskModel>>(
          stream: TaskService().getTasks(),
          builder: (context, snapshot) {
            final tasks = snapshot.data ?? [];

            final totalTasks = tasks.length;
            final completedTasks =
                tasks.where((task) => task.completed).length;
            final highPriorityTasks = tasks
                .where((task) => task.priority.toLowerCase() == 'high')
                .length;

            final progress = totalTasks == 0
                ? 0
                : ((completedTasks / totalTasks) * 100).round();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${greeting()} 👋',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Priora is ready to organize your day.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 26),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF4F46E5),
                          Color(0xFF7C3AED),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Today’s Focus',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          totalTasks == 0
                              ? 'No tasks yet. Start with a brain dump and Priora will organize your day.'
                              : 'You have $totalTasks tasks. $highPriorityTasks high-priority task${highPriorityTasks == 1 ? '' : 's'} need attention.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Productivity Snapshot',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: '$totalTasks',
                          label: 'Tasks',
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _StatCard(
                          value: '$progress%',
                          label: 'Progress',
                          icon: Icons.trending_up,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: '$completedTasks',
                          label: 'Completed',
                          icon: Icons.done_all,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _StatCard(
                          value: '$highPriorityTasks',
                          label: 'High Priority',
                          icon: Icons.priority_high,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Next Recommended Task',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _NextTaskCard(tasks: tasks),

                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: highPriorityTasks > 0
                          ? const Color(0xFFFFF1F2)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: highPriorityTasks > 0
                            ? const Color(0xFFFDA4AF)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: highPriorityTasks > 0
                              ? const Color(0xFFFFE4E6)
                              : const Color(0xFFFFF7ED),
                          child: Icon(
                            highPriorityTasks > 0
                                ? Icons.warning_amber_rounded
                                : Icons.lightbulb_outline,
                            color: highPriorityTasks > 0
                                ? const Color(0xFFE11D48)
                                : const Color(0xFFF97316),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            highPriorityTasks > 0
                                ? 'Rescue hint: Handle your high-priority tasks first to reduce deadline risk.'
                                : 'Rescue Mode will activate when Priora detects a deadline risk.',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NextTaskCard extends StatelessWidget {
  final List<TaskModel> tasks;

  const _NextTaskCard({required this.tasks});

  int priorityRank(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingTasks = tasks.where((task) => !task.completed).toList();

    pendingTasks.sort((a, b) {
      final priorityCompare =
          priorityRank(b.priority).compareTo(priorityRank(a.priority));

      if (priorityCompare != 0) return priorityCompare;

      return b.urgencyScore.compareTo(a.urgencyScore);
    });

    if (pendingTasks.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Text(
          'No pending tasks. Great job!',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      );
    }

    final task = pendingTasks.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFEEF2FF),
            child: Icon(
              Icons.play_arrow_rounded,
              color: Color(0xFF4F46E5),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${task.priority.toUpperCase()} • ${task.estimatedMinutes} min • Urgency ${task.urgencyScore}/10',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4F46E5)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}