import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String senderId;
  final String receiverId;
  final String text;
  final String chatId;
  final String senderName;
  final String senderUsername; // New field
  final DateTime timestamp;
  final bool isRead;

  AppNotification({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.chatId,
    required this.senderName,
    required this.senderUsername, // New field
    required this.timestamp,
    this.isRead = false,
  });

  factory AppNotification.fromMap(Map<String, dynamic> data) {
    return AppNotification(
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      text: data['text'] ?? '',
      chatId: data['chatId'] ?? '',
      senderName: data['senderName'] ?? 'Unknown Sender',
      senderUsername: data['senderUsername'] ?? '', // New field
      timestamp: (data['timestamp'] as Timestamp? ?? Timestamp.now()).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'chatId': chatId,
      'senderName': senderName,
      'senderUsername': senderUsername, // New field
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }
}
