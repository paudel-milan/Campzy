import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/post_model.dart';

class PostScreen extends StatelessWidget {
  final PostModel post;

  const PostScreen({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final commentController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Post by ${post.username}')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                Text(post.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(post.description),
                if (post.imageUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Image.network(post.imageUrl),
                  ),
                Divider(),
                Text('Comments', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(post.postId)
                      .collection('comments')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    final comments = snapshot.data!.docs;
                    return Column(
                      children: comments.map((doc) {
                        return ListTile(
                          title: Text(doc['username']),
                          subtitle: Text(doc['text']),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(hintText: 'Add a comment...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    final text = commentController.text.trim();
                    if (text.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('posts')
                          .doc(post.postId)
                          .collection('comments')
                          .add({
                        'text': text,
                        'username': 'Anonymous', // replace with user data
                        'timestamp': Timestamp.now(),
                      });
                      commentController.clear();
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
