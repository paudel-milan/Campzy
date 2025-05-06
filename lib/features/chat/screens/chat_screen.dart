import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerName;
  final String peerAvatarUrl;

  const ChatScreen({
    Key? key,
    required this.peerId,
    required this.peerName,
    required this.peerAvatarUrl,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  late String chatId; // Unique ID for the chat room

  @override
  void initState() {
    super.initState();
    // Create a unique chat ID by combining and sorting user IDs
    List<String> ids = [currentUserId, widget.peerId];
    ids.sort();
    chatId = ids.join('_');
  }

  Future<void> _sendMessage() async {
    String text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _messageController.clear();
      try {
        await FirebaseFirestore.instance.collection('messages').doc(chatId).collection('chats').add({
          'senderId': currentUserId,
          'receiverId': widget.peerId,
          'content': text,
          'timestamp': FieldValue.serverTimestamp(),
        });
        // Scroll to the bottom after sending a message
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        print("Error sending message: $e");
        // Optionally show an error message to the user
      }
    }
  }

  Widget _buildMessage(DocumentSnapshot document) {
    Map<String, dynamic> message = document.data() as Map<String, dynamic>;
    bool isMe = message['senderId'] == currentUserId;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isMe ? Colors.blue[200] : Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        message['content'],
        style: TextStyle(color: isMe ? Colors.white : Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.peerAvatarUrl),
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(width: 10),
            Text(
              widget.peerName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(chatId)
                  .collection('chats')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<DocumentSnapshot> messages = snapshot.data!.docs;
                // Scroll to the bottom initially and on new messages
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                });
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessage(messages[index]);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Send a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(), // Send message on Enter key
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}