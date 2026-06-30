import 'package:flutter/material.dart';

import '../../models/task_model.dart';
import '../../services/task_service.dart';

class RescueScreen extends StatelessWidget {
  const RescueScreen({super.key});

  int riskScore(TaskModel task) {
    int score = 0;

    if (task.priority.toLowerCase() == 'high') score += 40;
    if (task.priority.toLowerCase() == 'medium') score += 25;

    score += task.urgencyScore * 4;
    score += task.importanceScore * 3;

    if (task.deadline != null && task.deadline!.isNotEmpty) {
      score += 15;
    }

    return score.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        title: const Text('Rescue Mode'),
        backgroundColor: const Color(0xFFF8F7FF),
      ),
      body: SafeArea(
        child: StreamBuilder<List<TaskModel>>(
          stream: TaskService().getTasks(),
          builder: (context, snapshot) {
            final tasks = snapshot.data ?? [];

            final riskyTasks = tasks
                .where((task) => !task.completed)
                .where((task) =>
                    task.priority.toLowerCase() == 'high' ||
                    task.urgencyScore >= 7)
                .toList();

            riskyTasks.sort((a, b) => riskScore(b).compareTo(riskScore(a)));

            if (riskyTasks.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No critical deadline risks detected.\nYou are currently on track.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            }

            final topTask = riskyTasks.first;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFEF4444),
                          Color(0xFFF97316),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Rescue Mode Activated',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${riskyTasks.length} task${riskyTasks.length == 1 ? '' : 's'} need immediate attention.',
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Start Here',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _EmergencyTaskCard(task: topTask, score: riskScore(topTask)),

                  const SizedBox(height: 24),

                  const Text(
                    'Emergency Action Plan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _ActionStep(
                    number: '1',
                    title: 'Do only the highest-risk task first',
                    subtitle:
                        'Ignore low-priority work until this task is stabilized.',
                  ),
                  _ActionStep(
                    number: '2',
                    title: 'Use a focused work block',
                    subtitle:
                        'Work for ${topTask.estimatedMinutes > 60 ? 45 : topTask.estimatedMinutes} minutes without switching context.',
                  ),
                  _ActionStep(
                    number: '3',
                    title: 'Split if needed',
                    subtitle: topTask.canSplit
                        ? 'This task can be split into smaller steps.'
                        : 'This task should be handled as one focused block.',
                  ),
                  _ActionStep(
                    number: '4',
                    title: 'Recheck progress',
                    subtitle:
                        'After the focus block, mark progress and let Priora reprioritize.',
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Other Risky Tasks',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...riskyTasks.skip(1).map(
                        (task) => _SmallRiskCard(
                          task: task,
                          score: riskScore(task),
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

class _EmergencyTaskCard extends StatelessWidget {
  final TaskModel task;
  final int score;

  const _EmergencyTaskCard({
    required this.task,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Risk Score: $score/100',
            style: const TextStyle(
              color: Color(0xFFEF4444),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            task.reason,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniChip('${task.priority.toUpperCase()} priority'),
              _MiniChip('${task.estimatedMinutes} min'),
              _MiniChip('Urgency ${task.urgencyScore}/10'),
              _MiniChip('Importance ${task.importanceScore}/10'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallRiskCard extends StatelessWidget {
  final TaskModel task;
  final int score;

  const _SmallRiskCard({
    required this.task,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.priority_high,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task.title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            '$score',
            style: const TextStyle(
              color: Color(0xFFEF4444),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionStep extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;

  const _ActionStep({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFFE4E6),
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFFE11D48),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    height: 1.4,
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

class _MiniChip extends StatelessWidget {
  final String text;

  const _MiniChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFE11D48),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}