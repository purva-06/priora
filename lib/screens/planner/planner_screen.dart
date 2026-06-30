import 'package:flutter/material.dart';

import '../../models/task_model.dart';
import '../../services/task_service.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  Color priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF10B981);
    }
  }

  Color energyColor(String energy) {
    switch (energy.toLowerCase()) {
      case 'high':
        return const Color(0xFF7C3AED);
      case 'low':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF4F46E5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Planner',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your AI-generated tasks from brain dumps.',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: StreamBuilder<List<TaskModel>>(
                  stream: TaskService().getTasks(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    final tasks = snapshot.data ?? [];

                    if (tasks.isEmpty) {
                      return const Center(
                        child: Text(
                          'No tasks yet.\nCreate a Brain Dump first.',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: task.completed,
                                onChanged: (value) {
                                  TaskService().toggleTaskCompletion(
                                    task.id,
                                    value ?? false,
                                  );
                                },
                              ),
                              const SizedBox(width: 8),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        decoration: task.completed
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),

                                    if (task.project != null &&
                                        task.project!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        task.project!,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],

                                    const SizedBox(height: 10),

                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _Chip(
                                          text: task.priority.toUpperCase(),
                                          color: priorityColor(task.priority),
                                        ),
                                        _Chip(
                                          text: task.category,
                                          color: const Color(0xFF4F46E5),
                                        ),
                                        _Chip(
                                          text:
                                              '${task.estimatedMinutes} min',
                                          color: const Color(0xFF64748B),
                                        ),
                                        _Chip(
                                          text:
                                              '${task.energyLevel} energy',
                                          color: energyColor(task.energyLevel),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    Row(
                                      children: [
                                        _ScoreBadge(
                                          label: 'Urgency',
                                          score: task.urgencyScore,
                                        ),
                                        const SizedBox(width: 10),
                                        _ScoreBadge(
                                          label: 'Importance',
                                          score: task.importanceScore,
                                        ),
                                      ],
                                    ),

                                    if (task.deadline != null &&
                                        task.deadline!.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Text(
                                        'Deadline: ${task.deadline}',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],

                                    if (task.reason.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        task.reason,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],

                                    if (task.tags.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: task.tags
                                            .map(
                                              (tag) => _TagChip(text: tag),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;

  const _Chip({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final String label;
  final int score;

  const _ScoreBadge({
    required this.label,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: $score/10',
      style: TextStyle(
        color: Colors.grey.shade700,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String text;

  const _TagChip({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        '#$text',
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}