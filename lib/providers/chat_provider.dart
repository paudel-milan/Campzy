import 'package:flutter/material.dart';
import '../features/chat/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final TextEditingController messageController = TextEditingController();

  void send(String receiverId) {
    _chatService.sendMessage(receiverId, messageController.text);
    messageController.clear();
  }

  Stream<List<Map<String, dynamic>>> getMessages(String senderId, String receiverId) {
    return _chatService.getMessages(senderId, receiverId);
  }
}
