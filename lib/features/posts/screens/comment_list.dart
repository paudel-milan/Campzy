import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommentList extends StatelessWidget {
  final String postId;

  CommentList({required this.postId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No comments yet"));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var comment = snapshot.data!.docs[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: Text(comment['username'][0]), // Show first letter of username
              ),
              title: Text(comment['username']),
              subtitle: Text(comment['commentText']),
              trailing: Text(
                  "${(comment['timestamp'] as Timestamp).toDate().toLocal()}"), // Display timestamp
            );
          },
        );
      },
    );
  }
}
