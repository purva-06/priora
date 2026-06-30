import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../services/gemini_service.dart';
import 'analysis_result_screen.dart';
import '../../services/brain_dump_service.dart';

class BrainDumpScreen extends StatefulWidget {
  const BrainDumpScreen({super.key});

  @override
  State<BrainDumpScreen> createState() => _BrainDumpScreenState();
}

class _BrainDumpScreenState extends State<BrainDumpScreen> {
  final TextEditingController dumpController = TextEditingController();
  final stt.SpeechToText speech = stt.SpeechToText();

  bool isListening = false;
  bool speechAvailable = false;
  bool isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  Future<void> initSpeech() async {
    speechAvailable = await speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() => isListening = false);
          }
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => isListening = false);
        }
      },
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> toggleListening() async {
    if (!speechAvailable) {
      speechAvailable = await speech.initialize();
    }

    if (!isListening) {
      setState(() => isListening = true);

      await speech.listen(
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
        ),
        onResult: (result) {
          setState(() {
            dumpController.text = result.recognizedWords;
            dumpController.selection = TextSelection.fromPosition(
              TextPosition(offset: dumpController.text.length),
            );
          });
        },
      );
    } else {
      setState(() => isListening = false);
      await speech.stop();
    }
  }

  Future<void> analyzeBrainDump() async {
    if (dumpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write or speak something first')),
      );
      return;
    }

    setState(() => isAnalyzing = true);

    try {
  final result = await GeminiService().analyzeBrainDump(
    dumpController.text.trim(),
  );

  await BrainDumpService().saveAnalysis(
    rawText: dumpController.text.trim(),
    analysis: result,
  );

  if (!mounted) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AnalysisResultScreen(analysis: result),
    ),
  );
}catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => isAnalyzing = false);
      }
    }
  }

  @override
  void dispose() {
    dumpController.dispose();
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Brain Dump',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Write or speak everything on your mind. Priora will turn it into a clear action plan.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: dumpController,
                      minLines: 9,
                      maxLines: 15,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText:
                            'Example: I have to finish my PPT by Friday, study DSA, submit assignment tonight, buy groceries, and call mom...',
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: isAnalyzing ? null : toggleListening,
                        icon: Icon(isListening ? Icons.stop : Icons.mic),
                        label: Text(
                          isListening ? 'Stop Listening' : 'Voice Input',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: isListening
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF4F46E5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isListening
                      ? const Color(0xFFFFF1F2)
                      : const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Icon(
                      isListening
                          ? Icons.graphic_eq
                          : Icons.lightbulb_outline,
                      color: isListening
                          ? const Color(0xFFE11D48)
                          : const Color(0xFF4F46E5),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isListening
                            ? 'Listening... speak naturally.'
                            : 'Tip: You do not need to organize anything. Just write or speak naturally.',
                        style: TextStyle(
                          color: isListening
                              ? const Color(0xFF9F1239)
                              : const Color(0xFF3730A3),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: isAnalyzing ? null : analyzeBrainDump,
                  icon: isAnalyzing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    isAnalyzing ? 'Analyzing...' : 'Analyze with AI',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}