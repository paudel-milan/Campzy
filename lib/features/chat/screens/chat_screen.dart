import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:cached_network_image/cached_network_image.dart'; // For peer avatar
import 'package:google_fonts/google_fonts.dart'; // For consistent font styling

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerName;
  final String peerAvatarUrl;

  const ChatScreen({
    super.key,
    required this.peerId,
    required this.peerName,
    required this.peerAvatarUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  late String chatId;
  bool _isSending = false;

  final Color themeColor = const Color(0xFF7851A9); // Consistent theme color

  @override
  void initState() {
    super.initState();
    List<String> ids = [currentUserId, widget.peerId];
    ids.sort(); // Important to ensure chatId is consistent regardless of who initiates
    chatId = ids.join('_');
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    String text = _messageController.text.trim();
    if (text.isNotEmpty && !_isSending) {
      setState(() => _isSending = true);
      _messageController.clear();
      // _messageFocusNode.requestFocus(); // Keep focus after sending for quick follow-up

      try {
        final messageData = {
          'senderId': currentUserId,
          'receiverId': widget.peerId,
          'content': text,
          'timestamp': FieldValue.serverTimestamp(),
        };

        // Add message to chat
        await FirebaseFirestore.instance
            .collection('messages')
            .doc(chatId)
            .collection('chats')
            .add(messageData);

        // Create notification for the receiver
        // Fetch sender's details (username and profile pic) for the notification
        DocumentSnapshot senderUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .get();
        String senderUsername = (senderUserDoc.data() as Map<String, dynamic>)?['username'] ?? 'A user';
        String senderProfilePicUrl = (senderUserDoc.data() as Map<String, dynamic>)?['profilePic'] ?? '';

        await FirebaseFirestore.instance.collection('notifications').add({
          'senderId': currentUserId,
          'senderName': senderUsername, // Use fetched username
          'senderProfilePicUrl': senderProfilePicUrl, // Use fetched profile pic
          'receiverId': widget.peerId,
          'text': text, // The message content
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'new_message', // Notification type
          'relatedItemId': chatId, // Can be chatId or senderId if preferred for navigation
          'isRead': false,
        });

        // Scroll to the bottom after sending a message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent + 50, // Add some offset
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } catch (e) {
        print("Error sending message: $e");
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error sending message: ${e.toString()}')));
        }
      } finally {
        if (mounted) {
          setState(() => _isSending = false);
        }
      }
    }
  }

  Widget _buildMessageItem(DocumentSnapshot document, bool isDarkMode) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    bool isMe = data['senderId'] == currentUserId;

    // Message bubble styling
    final Color myMessageBubbleColor = themeColor; // Your app's primary theme color
    final Color peerMessageBubbleColor = isDarkMode ? const Color(0xFF3A3A3C) : Colors.grey[200]!;
    final Color myMessageTextColor = Colors.white;
    final Color peerMessageTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;

    final bubbleColor = isMe ? myMessageBubbleColor : peerMessageBubbleColor;
    final textColor = isMe ? myMessageTextColor : peerMessageTextColor;

    final borderRadius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(6), // Subtle "tail"
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(6), // Subtle "tail"
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          );

    // Timestamp formatting
    String timeString = '';
    if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
      Timestamp ts = data['timestamp'] as Timestamp;
      timeString = DateFormat('hh:mm a').format(ts.toDate()); // e.g., 05:08 PM
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75, // Max width for bubble
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Important for Column to wrap content
          children: [
            Text(
              data['content'] ?? '',
              style: TextStyle(fontSize: 15.5, color: textColor, height: 1.35),
            ),
            if (timeString.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  timeString,
                  style: TextStyle(
                    fontSize: 11,
                    color: textColor.withOpacity(0.75),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define colors based on theme
    final Color scaffoldBackgroundColor = isDarkMode ? Colors.black : Colors.grey[100]!;
    final Color appBarBackgroundColor = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final Color primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    // final Color secondaryTextColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
    final Color inputAreaBackgroundColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    final Color textFieldBackgroundColor = isDarkMode ? const Color(0xFF2C2C2E) : Colors.grey[100]!;


    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0.5, // Subtle shadow
        backgroundColor: appBarBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDarkMode ? Colors.white70 : Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0, // Remove default title spacing
        title: Row(
          children: [
            CircleAvatar(
              radius: 18, // Slightly smaller avatar in AppBar
              backgroundColor: themeColor.withOpacity(0.1),
              backgroundImage: widget.peerAvatarUrl.isNotEmpty
                  ? CachedNetworkImageProvider(widget.peerAvatarUrl)
                  : null,
              child: widget.peerAvatarUrl.isEmpty
                  ? Icon(Icons.person, size: 20, color: themeColor.withOpacity(0.8))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.peerName,
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                  fontSize: 17,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.more_vert, color: isDarkMode ? Colors.white70 : Colors.black54),
        //     onPressed: () { /* TODO: Implement chat options */ },
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(chatId)
                  .collection('chats')
                  .orderBy('timestamp', descending: false) // Oldest messages first
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: primaryTextColor)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: themeColor));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'No messages yet. Say hi! 👋',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[500] : Colors.grey[700]),
                      ),
                    ),
                  );
                }
                List<DocumentSnapshot> messages = snapshot.data!.docs;

                // Auto-scroll logic
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                     final maxScroll = _scrollController.position.maxScrollExtent;
                     final currentScroll = _scrollController.position.pixels;
                     // Only auto-scroll if near the bottom, to avoid disrupting user if they scrolled up
                     if (maxScroll - currentScroll <= 200.0) { // Threshold of 200px
                        _scrollController.animateTo(
                          maxScroll + 50, // Ensure it goes to the very end + a bit more
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                     }
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageItem(messages[index], isDarkMode);
                  },
                );
              },
            ),
          ),
          _buildMessageInputArea(isDarkMode, inputAreaBackgroundColor, textFieldBackgroundColor, primaryTextColor),
        ],
      ),
    );
  }

  Widget _buildMessageInputArea(bool isDarkMode, Color areaBgColor, Color fieldBgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: areaBgColor,
        border: Border(top: BorderSide(color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!, width: 0.5)),
        // boxShadow: [ // Optional: subtle shadow
        //   BoxShadow(
        //     color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
        //     blurRadius: 5,
        //     offset: const Offset(0, -2),
        //   )
        // ]
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end, // Align items to bottom for multiline TextField
          children: [
            // TODO: Add attachment button if needed
            // IconButton(
            //   icon: Icon(Icons.add_circle_outline, color: themeColor, size: 26),
            //   onPressed: () { /* Handle attachments */ },
            // ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: fieldBgColor,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _messageFocusNode,
                  style: TextStyle(color: textColor, fontSize: 15.5),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: isDarkMode ? Colors.grey[500] : Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Adjusted padding
                    isDense: true,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 5, // Allow multiline input
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent, // Make material transparent for InkWell ripple
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: _isSending ? null : _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(10.0), // Slightly smaller padding for just icon
                  decoration: BoxDecoration(
                     color: themeColor,
                     shape: BoxShape.circle
                  ),
                  child: _isSending
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}