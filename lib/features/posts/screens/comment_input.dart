import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommentInput extends StatelessWidget {
  final String postId;
  final String uid;

  CommentInput({required this.postId, required this.uid});

  @override
  Widget build(BuildContext context) {
    TextEditingController _commentController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _addComment(postId, _commentController.text, uid);
              _commentController.clear();
            },
          ),
        ],
      ),
    );
  }

  // Add comment to the post
  Future<void> _addComment(String postId, String commentText, String uid) async {
    if (commentText.isEmpty) return;

    // Fetch the username from Firestore
    var userData = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    String username = userData.data()?['username'] ?? 'Anonymous';

    // Store the comment in Firestore
    await FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').add({
      'commentText': commentText,
      'userUid': uid,
      'username': username,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
