import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, String> user;

  ChatScreen({required this.user});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> messages = [];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add({'text': _messageController.text.trim(), 'isMe': 'true'});
    });

    _messageController.clear();

    // Simulate a reply after a delay
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        messages.add({'text': 'Hey! How are you?', 'isMe': 'false'});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(radius: 20, // Adjust size as needed
                backgroundColor: Colors.grey[300], // Background color
                child: Icon(Icons.person, size: 24, color: Colors.white)),
            SizedBox(width: 10),
            Text(widget.user['name']!),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        bool isMe = messages[index]['isMe'] == 'true';
        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              messages[index]['text']!,
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          SizedBox(width: 10),
          IconButton(icon: Icon(Icons.send, color: Colors.blue), onPressed: _sendMessage),
        ],
      ),
    );
  }
}
