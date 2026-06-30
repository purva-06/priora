import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/task_model.dart';
import '../../services/task_service.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  Timer? timer;
  TaskModel? selectedTask;
  int remainingSeconds = 0;
  bool isRunning = false;

  void startFocus(TaskModel task) {
    timer?.cancel();

    setState(() {
      selectedTask = task;
      remainingSeconds = task.estimatedMinutes * 60;
      isRunning = true;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          remainingSeconds = 0;
          isRunning = false;
        });
        return;
      }

      setState(() {
        remainingSeconds--;
      });
    });
  }

  void stopFocus() {
    timer?.cancel();
    setState(() => isRunning = false);
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> markComplete() async {
    if (selectedTask == null) return;

    await TaskService().toggleTaskCompletion(selectedTask!.id, true);

    setState(() {
      selectedTask = null;
      remainingSeconds = 0;
      isRunning = false;
    });

    timer?.cancel();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SafeArea(
        child: StreamBuilder<List<TaskModel>>(
          stream: TaskService().getTasks(),
          builder: (context, snapshot) {
            final tasks = (snapshot.data ?? [])
                .where((task) => !task.completed)
                .toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Focus Mode',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pick one task and let Priora keep you on track.',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (selectedTask != null) _ActiveFocusCard(
                    task: selectedTask!,
                    time: formatTime(remainingSeconds),
                    isRunning: isRunning,
                    onPause: stopFocus,
                    onComplete: markComplete,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Choose a Task',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (tasks.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Text('No pending tasks available.'),
                      ),
                    )
                  else
                    ...tasks.map(
                      (task) => _FocusTaskCard(
                        task: task,
                        onStart: () => startFocus(task),
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

class _ActiveFocusCard extends StatelessWidget {
  final TaskModel task;
  final String time;
  final bool isRunning;
  final VoidCallback onPause;
  final VoidCallback onComplete;

  const _ActiveFocusCard({
    required this.task,
    required this.time,
    required this.isRunning,
    required this.onPause,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4F46E5),
            Color(0xFF7C3AED),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.timer, color: Colors.white, size: 34),
          const SizedBox(height: 18),
          const Text(
            'Working On',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            task.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 46,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPause,
                  icon: const Icon(Icons.pause),
                  label: Text(isRunning ? 'Pause' : 'Paused'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.done),
                  label: const Text('Complete'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4F46E5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FocusTaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onStart;

  const _FocusTaskCard({
    required this.task,
    required this.onStart,
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
          const CircleAvatar(
            backgroundColor: Color(0xFFEEF2FF),
            child: Icon(Icons.play_arrow_rounded, color: Color(0xFF4F46E5)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${task.priority.toUpperCase()} • ${task.estimatedMinutes} min',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onStart,
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}