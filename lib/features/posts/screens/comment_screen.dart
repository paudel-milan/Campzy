import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For better image handling
import 'package:google_fonts/google_fonts.dart'; // For AppBar title
import 'package:intl/intl.dart'; // For better timestamp formatting

class CommentScreen extends StatefulWidget {
  final String postId;

  const CommentScreen({super.key, required this.postId});

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode(); // To manage focus
  String _currentUserName = 'Anonymous';
  String _currentUserProfilePic = '';
  bool _isPostingComment = false;

  final Color themeColor = const Color(0xFF7851A9); // Consistent theme color

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserDetails();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && mounted) {
      try {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
        if (mounted && userDoc.exists) {
          setState(() {
            _currentUserName = userDoc.data()?['username'] ?? 'Anonymous';
            _currentUserProfilePic = userDoc.data()?['profilePic'] ?? '';
          });
        }
      } catch (e) {
        if (mounted) print("Error fetching user details: $e");
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty || _isPostingComment) return;

    setState(() => _isPostingComment = true);

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to comment.')),
        );
      }
      setState(() => _isPostingComment = false);
      return;
    }

    try {
      // Add comment to Firestore
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
            'comment': _commentController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
            'userId': user.uid,
            'username': _currentUserName,
            'profilePicUrl':
                _currentUserProfilePic, // Use 'profilePicUrl' for consistency
          });

      // Increment commentsCount on the post
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({'commentsCount': FieldValue.increment(1)});

      if (mounted) {
        _commentController.clear();
        _commentFocusNode.unfocus(); // Hide keyboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPostingComment = false);
      }
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    final DateTime date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return DateFormat.yMMMd().add_jm().format(
        date,
      ); // e.g., Sep 10, 2023, 5:08 PM
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBgColor = isDarkMode ? Colors.black : Colors.grey[50]!;
    final Color cardColor = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final Color inputFieldBgColor =
        isDarkMode ? const Color(0xFF2C2C2E) : Colors.grey[100]!;
    final Color textColor =
        isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final Color subtleTextColor =
        isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Comments",
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.postId)
                      .collection('comments')
                      .orderBy(
                        'createdAt',
                        descending: false,
                      ) // Show oldest comments first usually
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: themeColor),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error loading comments.",
                      style: TextStyle(color: textColor),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mode_comment_outlined,
                          size: 50,
                          color: subtleTextColor,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No comments yet",
                          style: TextStyle(
                            fontSize: 16,
                            color: subtleTextColor,
                          ),
                        ),
                        Text(
                          "Be the first to comment!",
                          style: TextStyle(
                            fontSize: 14,
                            color: subtleTextColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final comments = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 12.0,
                  ),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final commentData =
                        comments[index].data() as Map<String, dynamic>;
                    final String username =
                        commentData['username'] ?? 'Anonymous';
                    final String profilePicUrl =
                        commentData['profilePicUrl'] ?? '';
                    final String commentText = commentData['comment'] ?? '';
                    final Timestamp? createdAt =
                        commentData['createdAt'] as Timestamp?;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.08),
                        //     blurRadius: 6,
                        //     offset: const Offset(0, 2),
                        //   ),
                        // ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: themeColor.withOpacity(0.1),
                            backgroundImage:
                                profilePicUrl.isNotEmpty
                                    ? CachedNetworkImageProvider(profilePicUrl)
                                    : null,
                            child:
                                profilePicUrl.isEmpty
                                    ? Icon(
                                      Icons.person_outline,
                                      size: 20,
                                      color: themeColor.withOpacity(0.8),
                                    )
                                    : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      username,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatTimestamp(createdAt),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: subtleTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  commentText,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    color: textColor.withOpacity(0.85),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // TODO: Add options for comment like/reply/delete if needed
                          // Icon(Icons.more_vert, size: 18, color: subtleTextColor),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Comment Input Area
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: cardColor,
              boxShadow: [
                BoxShadow(
                  color:
                      isDarkMode
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              // Ensures input field is not obscured by system UI
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Current user's profile picture next to input field
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: themeColor.withOpacity(0.1),
                    backgroundImage:
                        _currentUserProfilePic.isNotEmpty
                            ? CachedNetworkImageProvider(_currentUserProfilePic)
                            : null,
                    child:
                        _currentUserProfilePic.isEmpty
                            ? Icon(
                              Icons.person,
                              size: 20,
                              color: themeColor.withOpacity(0.8),
                            )
                            : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      focusNode: _commentFocusNode,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(color: subtleTextColor),
                        filled: true,
                        fillColor: inputFieldBgColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        isDense: true,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _addComment(),
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon:
                        _isPostingComment
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: themeColor,
                              ),
                            )
                            : Icon(Icons.send_rounded, color: themeColor),
                    onPressed: _isPostingComment ? null : _addComment,
                    padding: EdgeInsets.zero, // Remove default padding
                    constraints:
                        const BoxConstraints(), // Remove default constraints
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
