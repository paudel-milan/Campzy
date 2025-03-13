import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/post_service.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _controller = TextEditingController();
  final PostService _postService = PostService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Create Post')),
      body: user == null
          ? Center(child: Text("You need to log in to create a post"))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Enter your post'),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_controller.text.trim().isEmpty) return;

                await _postService.createPost(
                  text: _controller.text.trim(),
                  authorId: user.uid,
                  username: user.displayName ?? 'Anonymous',
                );

                _controller.clear(); // ✅ Clears text after posting
                Navigator.pop(context); // ✅ Navigates back
              },
              child: Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
