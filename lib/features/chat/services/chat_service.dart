import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  // Helper function to generate unique chat ID
  String getChatId(String peerId) {
    final ids = [currentUserId, peerId]..sort();
    return ids.join('_');
  }

  // Get all messages for a chat between two users
  Stream<List<Map<String, dynamic>>> getMessages(String senderId, String receiverId) {
    final chatId = getChatId(receiverId);
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).cast<Map<String, dynamic>>().toList());
  }

  // Send a message in a chat
  Future<void> sendMessage(String receiverId, String text) async {
    final chatId = getChatId(receiverId);

    // Ensure that chat document exists in Firestore
    await _ensureChatExists(chatId, receiverId);

    if (text.trim().isEmpty) return;

    await _db.collection('chats').doc(chatId).collection('messages').add({
      'senderId': currentUserId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Ensure that chat document exists for the two users
  Future<void> _ensureChatExists(String chatId, String peerId) async {
    final chatDoc = await _db.collection('chats').doc(chatId).get();

    if (!chatDoc.exists) {
      // Create the chat document if it doesn't exist
      await _db.collection('chats').doc(chatId).set({
        'participants': [currentUserId, peerId],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Get a list of all users' chats (if necessary, could also be fetched by chat home)
  Future<List<Map<String, dynamic>>> getUserChats() async {
    final chatDocs = await _db
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .get();

    return chatDocs.docs.map((doc) => doc.data()).toList();
  }
}
