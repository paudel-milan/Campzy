import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../screens/comment_screen.dart'; // Assuming this path is correct
import '/models/post_model.dart'; // Assuming this path is correct

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late int upvotes;
  late int downvotes;
  bool hasUpvoted = false;
  bool hasDownvoted = false;
  bool _isDisposed = false; // To prevent setState calls on disposed widget

  // It's safer to get UID and handle potential null.
  // However, if PostCard is always used in a context where user is logged in, direct access might be acceptable.
  // For robustness, it's good practice to check.
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  final Color themeColor = const Color(0xFF7851A9); // Consistent theme color

  @override
  void initState() {
    super.initState();
    upvotes =
        widget.post.upvotes; // Use direct value, default handled in PostModel
    downvotes = widget.post.downvotes;
    if (currentUserId != null) {
      _fetchUserVoteStatus();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _fetchUserVoteStatus() async {
    if (currentUserId == null || _isDisposed) return;

    try {
      final voteDoc =
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.post.postId)
              .collection('votes')
              .doc(currentUserId!)
              .get();

      if (!_isDisposed && voteDoc.exists) {
        final voteType = voteDoc.data()!['voteType'];
        setState(() {
          hasUpvoted = voteType == 'upvote';
          hasDownvoted = voteType == 'downvote';
        });
      }
    } catch (e) {
      if (!_isDisposed) {
        print("Error fetching vote status: $e");
      }
    }
  }

  Future<void> _handleUpvote() async {
    if (currentUserId == null || _isDisposed) return;
    final String userId = currentUserId!;

    final postRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.postId);
    final voteRef = postRef.collection('votes').doc(userId);
    WriteBatch batch = FirebaseFirestore.instance.batch();

    if (hasUpvoted) {
      // Remove upvote
      if (!_isDisposed) {
        setState(() {
          upvotes--;
          hasUpvoted = false;
        });
      }
      batch.delete(voteRef);
      batch.update(postRef, {'upvotes': FieldValue.increment(-1)});
    } else {
      // Add upvote or switch from downvote
      bool wasPreviouslyDownvoted = hasDownvoted;
      if (!_isDisposed) {
        setState(() {
          upvotes++;
          hasUpvoted = true;
          if (wasPreviouslyDownvoted) {
            downvotes--;
            hasDownvoted = false;
          }
        });
      }

      batch.set(voteRef, {'voteType': 'upvote'});
      batch.update(postRef, {'upvotes': FieldValue.increment(1)});
      if (wasPreviouslyDownvoted) {
        batch.update(postRef, {'downvotes': FieldValue.increment(-1)});
      }
    }
    try {
      await batch.commit();
    } catch (e) {
      if (!_isDisposed) {
        print("Error handling upvote: $e");
        // Optionally revert UI state or show error
      }
    }
  }

  Future<void> _handleDownvote() async {
    if (currentUserId == null || _isDisposed) return;
    final String userId = currentUserId!;

    final postRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.postId);
    final voteRef = postRef.collection('votes').doc(userId);
    WriteBatch batch = FirebaseFirestore.instance.batch();

    if (hasDownvoted) {
      // Remove downvote
      if (!_isDisposed) {
        setState(() {
          downvotes--;
          hasDownvoted = false;
        });
      }
      batch.delete(voteRef);
      batch.update(postRef, {'downvotes': FieldValue.increment(-1)});
    } else {
      // Add downvote or switch from upvote
      bool wasPreviouslyUpvoted = hasUpvoted;
      if (!_isDisposed) {
        setState(() {
          downvotes++;
          hasDownvoted = true;
          if (wasPreviouslyUpvoted) {
            upvotes--;
            hasUpvoted = false;
          }
        });
      }
      batch.set(voteRef, {'voteType': 'downvote'});
      batch.update(postRef, {'downvotes': FieldValue.increment(1)});
      if (wasPreviouslyUpvoted) {
        batch.update(postRef, {'upvotes': FieldValue.increment(-1)});
      }
    }
    try {
      await batch.commit();
    } catch (e) {
      if (!_isDisposed) {
        print("Error handling downvote: $e");
        // Optionally revert UI state or show error
      }
    }
  }

  Future<void> _deletePost() async {
    if (currentUserId == null || widget.post.uid != currentUserId) return;

    // Optional: Show confirmation dialog
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Post?'),
          content: const Text(
            'Are you sure you want to delete this post? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.post.postId)
            .delete();
        if (!_isDisposed && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully')),
          );
          // You might want a callback to notify the parent list to refresh
        }
      } catch (e) {
        if (!_isDisposed && mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting post: $e')));
        }
      }
    }
  }

  Widget _buildInteractionButton({
    required IconData icon,
    String? text,
    required Color color,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor =
        themeColor; // Use main theme color for active upvote
    final Color baseIconColor =
        isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
    final Color currentIconColor =
        isActive
            ? (icon == Icons.thumb_up_alt_rounded
                ? activeColor
                : Colors.redAccent)
            : color;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: currentIconColor, size: 20),
            if (text != null) ...[
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  color:
                      currentIconColor, // Text color matches icon when active
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final subtleTextColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
    final cardBackgroundColor =
        isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final baseIconColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

    return Card(
      color: cardBackgroundColor,
      elevation: isDarkMode ? 1 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info, timestamp, and actions
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: themeColor.withOpacity(0.1),
                  backgroundImage:
                      widget.post.profilePicUrl.isNotEmpty
                          ? CachedNetworkImageProvider(
                            widget.post.profilePicUrl,
                          )
                          : null,
                  child:
                      widget.post.profilePicUrl.isEmpty
                          ? Icon(Icons.person, size: 22, color: themeColor)
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                      Text(
                        "Posted ${DateFormat.yMMMd().add_jm().format((widget.post.createdAt).toDate())}",
                        style: TextStyle(fontSize: 12, color: subtleTextColor),
                      ),
                    ],
                  ),
                ),
                if (currentUserId != null && widget.post.uid == currentUserId)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'Delete') {
                        _deletePost();
                      }
                    },
                    icon: Icon(Icons.more_vert, color: subtleTextColor),
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'Delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete Post'),
                              ],
                            ),
                          ),
                        ],
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            if (widget.post.title.isNotEmpty) ...[
              Text(
                widget.post.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  height: 1.3,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
            ],

            // Description
            if (widget.post.description.isNotEmpty)
              Text(
                widget.post.description,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            const SizedBox(height: 12),

            // Image
            if (widget.post.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: widget.post.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity, // Make image take available width
                  placeholder:
                      (context, url) => Container(
                        height: 200, // Placeholder height
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(color: themeColor),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        height: 200, // Error placeholder height
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        child: Icon(
                          Icons.broken_image,
                          color: subtleTextColor,
                          size: 40,
                        ),
                      ),
                ),
              ),
            if (widget.post.imageUrl.isNotEmpty) const SizedBox(height: 12),

            Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
            const SizedBox(height: 4),

            // Interactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildInteractionButton(
                      icon:
                          hasUpvoted
                              ? Icons.thumb_up_alt_rounded
                              : Icons.thumb_up_alt_outlined,
                      text: '$upvotes',
                      color: baseIconColor,
                      isActive: hasUpvoted,
                      onPressed: _handleUpvote,
                    ),
                    const SizedBox(width: 12),
                    _buildInteractionButton(
                      icon:
                          hasDownvoted
                              ? Icons.thumb_down_alt_rounded
                              : Icons.thumb_down_alt_outlined,
                      text: '$downvotes',
                      color: baseIconColor,
                      isActive: hasDownvoted,
                      onPressed: _handleDownvote,
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildInteractionButton(
                      icon: Icons.mode_comment_outlined,
                      text: '${widget.post.commentsCount}',
                      color: baseIconColor,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    CommentScreen(postId: widget.post.postId),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildInteractionButton(
                      icon: Icons.share_outlined,
                      color: baseIconColor,
                      onPressed: () {
                        // TODO: Implement share feature
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Share (Not implemented yet)'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
