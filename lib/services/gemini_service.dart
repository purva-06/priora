import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env');
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
  }

  Future<Map<String, dynamic>> analyzeBrainDump(String brainDump) async {
    final now = DateTime.now();

    final currentDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final prompt = '''
You are Priora, an AI productivity assistant.

Today's date is $currentDate.

Convert the user's brain dump into structured productivity data.

Return ONLY valid JSON.
Do not use markdown.
Do not add explanation.
Do not wrap the response in ```json.

Important deadline rules:
- Never generate a deadline before today's date.
- If the user does not mention a deadline, use null.
- If the user says "today", use $currentDate.
- If the user says "tomorrow", calculate the actual date after $currentDate.
- If the user mentions a weekday like "Friday", use the next upcoming Friday from $currentDate.
- If the date is unclear, use null.

Priority rules:
- high = urgent deadline, important work, exams, submissions, interviews, bills
- medium = important but not immediately urgent
- low = optional or flexible task

Return JSON in exactly this structure:
{
  "summary": "short summary",
  "tasks": [
    {
      "title": "task title",
      "category": "work/study/personal/health/finance/other",
      "priority": "high/medium/low",
      "estimatedMinutes": 30,
      "deadline": "YYYY-MM-DD or null",
      "reason": "why this priority was assigned",
      "urgencyScore": 1,
      "importanceScore": 1,
      "energyLevel": "low/medium/high",
      "canSplit": true,
      "project": "project name or null",
      "tags": ["tag1", "tag2"]
    }
  ],
  "dailyPlan": [
    {
      "time": "09:00-10:00",
      "task": "task title"
    }
  ],
  "riskLevel": "low/medium/high",
  "recommendation": "one useful productivity recommendation"
}

User brain dump:
$brainDump
''';

    final response = await _model.generateContent([
      Content.text(prompt),
    ]);

    final text = response.text;

    if (text == null || text.trim().isEmpty) {
      throw Exception('Gemini returned empty response');
    }

    final cleanedText = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    try {
      return jsonDecode(cleanedText) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Invalid JSON from Gemini: $cleanedText');
    }
  }
  Future<Map<String, dynamic>> replanSchedule({
  required String userMessage,
  required List<Map<String, dynamic>> tasks,
}) async {
  final now = DateTime.now();

  final currentDate =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

  final prompt = '''
You are Priora, an AI scheduling assistant.

Today's date is $currentDate.

The user wants to modify their current task schedule.

Your job:
- Understand the user's request.
- Reassign estimated time for tasks if needed.
- Keep urgent and important tasks protected.
- Reduce or move low-priority tasks when time is limited.
- Return ONLY valid JSON.
- Do not use markdown.
- Do not explain outside JSON.

Current tasks:
${jsonEncode(tasks)}

User request:
$userMessage

Return JSON in exactly this structure:
{
  "summary": "short explanation of what changed",
  "updatedTasks": [
    {
      "taskId": "existing task id",
      "title": "task title",
      "estimatedMinutes": 30,
      "reason": "why this time was assigned"
    }
  ],
  "recommendation": "one useful next action"
}
''';

  final response = await _model.generateContent([
    Content.text(prompt),
  ]);

  final text = response.text;

  if (text == null || text.trim().isEmpty) {
    throw Exception('Gemini returned empty response');
  }

  final cleanedText = text
      .replaceAll('```json', '')
      .replaceAll('```', '')
      .trim();

  try {
    return jsonDecode(cleanedText) as Map<String, dynamic>;
  } catch (_) {
    throw Exception('Invalid JSON from Gemini: $cleanedText');
  }
}
}