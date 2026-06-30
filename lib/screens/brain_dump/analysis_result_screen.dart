import 'package:flutter/material.dart';

class AnalysisResultScreen extends StatelessWidget {
  final Map<String, dynamic> analysis;

  const AnalysisResultScreen({
    super.key,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    final tasks = List<Map<String, dynamic>>.from(analysis['tasks'] ?? []);
    final dailyPlan =
        List<Map<String, dynamic>>.from(analysis['dailyPlan'] ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        title: const Text('AI Analysis'),
        backgroundColor: const Color(0xFFF8F7FF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderCard(
              summary: analysis['summary'] ?? 'No summary available',
              riskLevel: analysis['riskLevel'] ?? 'unknown',
            ),

            const SizedBox(height: 24),

            const Text(
              'Extracted Tasks',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),

            ...tasks.map((task) => _TaskCard(task: task)),

            const SizedBox(height: 24),

            const Text(
              'Suggested Plan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),

            ...dailyPlan.map((plan) => _PlanCard(plan: plan)),

            const SizedBox(height: 24),

            _RecommendationCard(
              recommendation:
                  analysis['recommendation'] ?? 'No recommendation available.',
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String summary;
  final String riskLevel;

  const _HeaderCard({
    required this.summary,
    required this.riskLevel,
  });

  Color getRiskColor() {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
          const SizedBox(height: 16),
          const Text(
            'AI Analysis Complete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            summary,
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: getRiskColor(),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Risk: ${riskLevel.toUpperCase()}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Map<String, dynamic> task;

  const _TaskCard({required this.task});

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
          const Icon(Icons.check_circle_outline, color: Color(0xFF4F46E5)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'] ?? 'Untitled Task',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${task['priority'] ?? 'medium'} priority • ${task['estimatedMinutes'] ?? 0} min',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;

  const _PlanCard({required this.plan});

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
          const Icon(Icons.schedule, color: Color(0xFF4F46E5)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '${plan['time'] ?? 'Anytime'} → ${plan['task'] ?? ''}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final String recommendation;

  const _RecommendationCard({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Color(0xFF4F46E5)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation,
              style: const TextStyle(
                color: Color(0xFF3730A3),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}