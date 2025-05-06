import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../screens/comment_screen.dart';
import '/models/post_model.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int upvotes = 0;
  int downvotes = 0;
  bool hasUpvoted = false;
  bool hasDownvoted = false;

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    upvotes = widget.post.upvotes ?? 0;
    downvotes = widget.post.downvotes ?? 0;
    _fetchUserVoteStatus();
  }

  Future<void> _fetchUserVoteStatus() async {
    final voteDoc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.postId)
        .collection('votes')
        .doc(userId)
        .get();

    if (voteDoc.exists) {
      final voteType = voteDoc.data()!['voteType'];
      setState(() {
        hasUpvoted = voteType == 'upvote';
        hasDownvoted = voteType == 'downvote';
      });
    }
  }

  Future<void> _handleUpvote() async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.post.postId);
    final voteRef = postRef.collection('votes').doc(userId);

    if (hasUpvoted) {
      // Remove upvote
      setState(() => upvotes--);
      await voteRef.delete();
      await postRef.update({'upvotes': FieldValue.increment(-1)});
    } else {
      // Add upvote
      setState(() {
        upvotes++;
        if (hasDownvoted) {
          downvotes--;
          hasDownvoted = false;
        }
        hasUpvoted = true;
      });

      await voteRef.set({'voteType': 'upvote'});
      await postRef.update({
        'upvotes': FieldValue.increment(1),
        'downvotes': hasDownvoted ? FieldValue.increment(-1) : FieldValue.increment(0),
      });

      // Remove previous downvote if it existed
      if (hasDownvoted) {
        await voteRef.set({'voteType': 'upvote'});
      }
    }
  }

  Future<void> _handleDownvote() async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.post.postId);
    final voteRef = postRef.collection('votes').doc(userId);

    if (hasDownvoted) {
      // Remove downvote
      setState(() => downvotes--);
      await voteRef.delete();
      await postRef.update({'downvotes': FieldValue.increment(-1)});
    } else {
      // Add downvote
      setState(() {
        downvotes++;
        if (hasUpvoted) {
          upvotes--;
          hasUpvoted = false;
        }
        hasDownvoted = true;
      });

      await voteRef.set({'voteType': 'downvote'});
      await postRef.update({
        'downvotes': FieldValue.increment(1),
        'upvotes': hasUpvoted ? FieldValue.increment(-1) : FieldValue.increment(0),
      });

      // Remove previous upvote if it existed
      if (hasUpvoted) {
        await voteRef.set({'voteType': 'downvote'});
      }
    }
  }

  Future<void> _deletePost() async {
    await FirebaseFirestore.instance.collection('posts').doc(widget.post.postId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? Colors.black : Colors.white;
    final iconColor = isDarkMode ? Colors.white : Colors.black54;
    final upvoteColor = hasUpvoted ? Colors.blue : iconColor;
    final downvoteColor = hasDownvoted ? Colors.red : iconColor;

    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info and delete
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: widget.post.profilePicUrl.isNotEmpty
                      ? NetworkImage(widget.post.profilePicUrl)
                      : null,
                  child: widget.post.profilePicUrl.isEmpty ? Icon(Icons.person) : null,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(widget.post.username,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'Delete') {
                      _deletePost();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'Delete', child: Text('Delete Post')),
                  ],
                  icon: Icon(Icons.more_vert, color: iconColor),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Title
            Text(widget.post.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
            SizedBox(height: 5),

            // Description
            Text(widget.post.description,
                style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.grey[400] : Colors.grey[700])),
            SizedBox(height: 10),

            // Image
            if (widget.post.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(widget.post.imageUrl, fit: BoxFit.cover),
              ),
            SizedBox(height: 10),

            // Date
            Text(
              "Posted on ${DateFormat.yMMMd().format((widget.post.createdAt as Timestamp).toDate())}",
              style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.grey[500] : Colors.grey),
            ),
            SizedBox(height: 10),

            // Interactions
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_upward, color: upvoteColor),
                  onPressed: _handleUpvote,
                ),
                Text('$upvotes', style: TextStyle(color: textColor)),
                IconButton(
                  icon: Icon(Icons.arrow_downward, color: downvoteColor),
                  onPressed: _handleDownvote,
                ),
                Text('$downvotes', style: TextStyle(color: textColor)),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.comment, color: iconColor),
                  onPressed: () {
                    // Navigate to comment screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentScreen(postId: widget.post.postId),
                      ),
                    );
                  },
                ),
                Text('${widget.post.commentsCount}', style: TextStyle(color: textColor)),
                IconButton(
                  icon: Icon(Icons.share, color: iconColor),
                  onPressed: () {
                    // Share feature
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
