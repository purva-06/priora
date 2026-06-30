import 'package:flutter/material.dart';

import '../../models/chat_message_model.dart';
import '../../services/chat_service.dart';
import '../../services/gemini_service.dart';
import '../../services/task_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController messageController = TextEditingController();

  bool isLoading = false;

  Future<void> sendMessage() async {
    final message = messageController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type your request first')),
      );
      return;
    }

    setState(() => isLoading = true);
    messageController.clear();

    try {
      await ChatService().addUserMessage(message);

      final tasks = await TaskService().getTasksOnce();

      final taskPayload = tasks
          .where((task) => !task.completed)
          .map((task) => task.toJson())
          .toList();

      final result = await GeminiService().replanSchedule(
        userMessage: message,
        tasks: taskPayload,
      );

      await ChatService().addAssistantMessage(
        text: result['summary'] ?? 'I created a new schedule suggestion.',
        proposedPlan: result,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> applyChanges(ChatMessageModel message) async {
    final proposedPlan = message.proposedPlan;
    if (proposedPlan == null) return;

    final updatedTasks = List<Map<String, dynamic>>.from(
      proposedPlan['updatedTasks'] ?? [],
    );

    await TaskService().applyScheduleChanges(updatedTasks);
    await ChatService().markApplied(message.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Schedule updated successfully')),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Chat',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ask Priora to reassign time based on your situation.',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: StreamBuilder<List<ChatMessageModel>>(
                stream: ChatService().getMessages(),
                builder: (context, snapshot) {
                  final messages = snapshot.data ?? [];

                  if (messages.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Text(
                          'No chat yet.\nTry: “I only have 2 hours tonight.”',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(18),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];

                      if (message.role == 'user') {
                        return _UserBubble(text: message.text);
                      }

                      return _AssistantBubble(
                        message: message,
                        onApply: () => applyChanges(message),
                      );
                    },
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Tell Priora your time changed...',
                        filled: true,
                        fillColor: const Color(0xFFF8F7FF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFF4F46E5),
                    child: IconButton(
                      onPressed: isLoading ? null : sendMessage,
                      icon: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String text;

  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 60),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF4F46E5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, height: 1.4),
        ),
      ),
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  final ChatMessageModel message;
  final VoidCallback onApply;

  const _AssistantBubble({
    required this.message,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final proposedPlan = message.proposedPlan;
    final updatedTasks = proposedPlan == null
        ? <Map<String, dynamic>>[]
        : List<Map<String, dynamic>>.from(proposedPlan['updatedTasks'] ?? []);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 36),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: Color(0xFFEEF2FF),
                  child: Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Color(0xFF4F46E5),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Priora',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              message.text,
              style: TextStyle(
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),

            if (updatedTasks.isNotEmpty) ...[
              const SizedBox(height: 14),

              ...updatedTasks.map(
                (task) => _ScheduleItem(task: task),
              ),

              const SizedBox(height: 12),

              if (proposedPlan?['recommendation'] != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    proposedPlan!['recommendation'],
                    style: const TextStyle(
                      color: Color(0xFF3730A3),
                      height: 1.4,
                    ),
                  ),
                ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: message.applied ? null : onApply,
                  icon: Icon(
                    message.applied ? Icons.check : Icons.done_all,
                  ),
                  label: Text(
                    message.applied ? 'Applied' : 'Apply Changes',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: message.applied
                        ? Colors.grey
                        : const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final Map<String, dynamic> task;

  const _ScheduleItem({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.schedule,
            color: Color(0xFF4F46E5),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              task['title'] ?? 'Task',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            '${task['estimatedMinutes'] ?? 0} min',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}