import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentScreen extends StatefulWidget {
  final String postId;

  const CommentScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  String userName = 'Anonymous';  // Default username if not available
  String userProfilePic = '';  // Default profilePic URL if not available

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  // Fetch the user's name and profile picture from the Firestore 'users' collection
  Future<void> _fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['username'] ?? 'Anonymous';  // Use username or fallback to 'Anonymous'
          userProfilePic = userDoc['profilePic'] ?? '';  // Get profilePic or use default
        });
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      // Get the current user information
      User? user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'comment': _commentController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': user?.uid,
        'username': userName,  // Store the fetched username
        'profilePic': userProfilePic.isEmpty ? 'https://www.iconfinder.com/icons/4032562/anonymous_avatar_circle_user_icon' : userProfilePic,  // Store profilePic, or default icon
      });

      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Comments')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.postId)
                    .collection('comments')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final comments = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      String? profilePic = comment['profilePic'];  // May be null

                      // Check if profilePic is null or empty and set default
                      String displayPic = (profilePic != null && profilePic.isNotEmpty)
                          ? profilePic
                          : 'https://www.iconfinder.com/icons/4032562/anonymous_avatar_circle_user_icon';  // Default anonymous icon URL

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User's profile picture
                            CircleAvatar(
                              backgroundImage: NetworkImage(displayPic),
                              child: profilePic == null || profilePic.isEmpty ? Icon(Icons.person) : null,
                            ),
                            SizedBox(width: 10),

                            // Comment content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Username and timestamp
                                  Row(
                                    children: [
                                      Text(
                                        comment['username'] ?? 'Anonymous',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        _formatTimestamp(comment['createdAt']),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Comment text
                                  SizedBox(height: 4),
                                  Text(comment['comment']),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Comment input field
            Padding(
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
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _addComment,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    return '${date.hour}:${date.minute < 10 ? '0${date.minute}' : date.minute}';
  }
}
