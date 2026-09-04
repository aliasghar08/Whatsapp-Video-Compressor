import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ai_support_provider.dart';
import '../widgets/chat_widgets.dart';

class AiSupportScreen extends ConsumerStatefulWidget {
  const AiSupportScreen({super.key});

  @override
  ConsumerState<AiSupportScreen> createState() => _AiSupportScreenState();
}

class _AiSupportScreenState extends ConsumerState<AiSupportScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text;
    if (text.trim().isNotEmpty) {
      ref.read(aiSupportProvider.notifier).sendMessage(text);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiSupportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Support Assistant'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E1E1E),
              Color(0xFF121212),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: aiState.messages.length,
                itemBuilder: (context, index) {
                  final message = aiState.messages[index];
                  return ChatMessageBubble(message: message);
                },
              ),
            ),
            if (aiState.isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            ChatInputArea(controller: _textController, onSend: _sendMessage),
          ],
        ),
      ),
    );
  }
}
