import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_ai/firebase_ai.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  
  ChatMessage({required this.text, required this.isUser});
}

class AiSupportState {
  final List<ChatMessage> messages;
  final bool isLoading;

  AiSupportState({
    required this.messages,
    this.isLoading = false,
  });

  AiSupportState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
  }) {
    return AiSupportState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final aiSupportProvider = NotifierProvider<AiSupportNotifier, AiSupportState>(() {
  return AiSupportNotifier();
});

class AiSupportNotifier extends Notifier<AiSupportState> {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  AiSupportState build() {
    final googleAI = FirebaseAI.googleAI();
    
    _model = googleAI.generativeModel(
      model: 'gemini-flash-latest',
      systemInstruction: Content.system(
        'You are a helpful, friendly AI support assistant for PureStatus, a WhatsApp video compression app. '
        'You help users understand how to compress videos and photos for WhatsApp status in HD.',
      ),
    );
    
    _chat = _model.startChat();
    
    return AiSupportState(messages: [
      ChatMessage(
        text: "Hi there! I'm your PureStatus AI Assistant. How can I help you today?", 
        isUser: false
      )
    ]);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(text: text, isUser: true);
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    try {
      final response = await _chat.sendMessage(Content.text(text));
      final responseText = response.text;
      
      if (responseText != null) {
        state = state.copyWith(
          messages: [...state.messages, ChatMessage(text: responseText, isUser: false)],
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          messages: [...state.messages, ChatMessage(text: "Sorry, I couldn't generate a response.", isUser: false)],
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint("Error sending message to AI: $e");
      state = state.copyWith(
        messages: [...state.messages, ChatMessage(text: "An error occurred while connecting to support. Please try again later.", isUser: false)],
        isLoading: false,
      );
    }
  }
}
