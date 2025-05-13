import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart'; // For profile pics
import 'package:google_fonts/google_fonts.dart'; // For AppBar title
import 'package:intl/intl.dart'; // For timestamp formatting

// Assuming correct paths for your project structure
import '../chat/screens/chat_screen.dart';
// Your AppNotification model (keep it simple if the previous one was an issue)
// For this example, I'll assume a very basic structure based on your original code.
// If you have a model, ensure it just maps fields directly.

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  final Color themeColor = const Color(0xFF7851A9); // Consistent theme color

  Future<void> _markAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      // print('Notification $notificationId marked as read.'); // Optional: for debugging
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final DateTime date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) return DateFormat.yMMMd().format(date);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define colors for UI consistency
    final Color scaffoldBackgroundColor =
        isDarkMode ? Colors.black : Colors.grey[100]!;
    final Color appBarBackgroundColor =
        isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final Color cardBackgroundColor =
        isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color primaryTextColor =
        isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final Color secondaryTextColor =
        isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
    final Color unreadHighlightColor = themeColor.withOpacity(0.07);

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            "Notifications",
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
            ),
          ),
          backgroundColor: appBarBackgroundColor,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Text(
            "Please log in to see notifications.",
            style: TextStyle(color: primaryTextColor, fontSize: 16),
          ),
        ),
      );
    }
    final String currentUserId = currentUser.uid;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryTextColor,
          ),
        ),
        backgroundColor: appBarBackgroundColor,
        elevation: 0.5, // Subtle elevation
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('notifications')
                .where('receiverId', isEqualTo: currentUserId)
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: themeColor));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: primaryTextColor),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_paused_outlined,
                      size: 60,
                      color: secondaryTextColor.withOpacity(0.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No Notifications",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "You're all caught up! We'll let you know when there's something new.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: docs.length,
            separatorBuilder:
                (context, index) => Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 70, // Start after the avatar space
                  endIndent: 16,
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                ),
            itemBuilder: (context, index) {
              final docSnapshot = docs[index];
              // Directly access data, assuming your Firestore structure
              final data = docSnapshot.data() as Map<String, dynamic>;

              final String senderName = data['senderName'] ?? 'Notification';
              final String text =
                  data['text'] ?? 'You have a new notification.';
              final Timestamp? timestamp = data['timestamp'] as Timestamp?;
              final bool isRead = data['isRead'] ?? false;
              final String senderId =
                  data['senderId'] ?? ''; // Needed for navigation
              // Assuming 'senderProfilePicUrl' field might exist in your notification document
              final String senderProfilePicUrl =
                  data['senderProfilePicUrl'] ?? '';
              // final String chatId = data['chatId'] ?? ''; // If you use chatId for navigation

              // Determine icon based on read status (simple version)
              IconData leadingIconData =
                  isRead
                      ? Icons.mark_email_read_outlined
                      : Icons.notifications_active_rounded;
              Color leadingIconColor = isRead ? secondaryTextColor : themeColor;

              // If it's a message type notification and you store sender's pic, use it
              // You can extend this logic for other notification types if needed
              bool isMessageType =
                  data['type'] == 'new_message'; // Example type check

              return InkWell(
                onTap: () async {
                  if (!isRead) {
                    await _markAsRead(docSnapshot.id);
                  }
                  // Simplified navigation based on your original code
                  // This assumes 'senderId' is the peerId for the chat.
                  // If 'chatId' is available and your ChatScreen uses it, adapt accordingly.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ChatScreen(
                            peerId: senderId,
                            peerName: senderName,
                            peerAvatarUrl:
                                senderProfilePicUrl, // Pass the fetched or default pic
                          ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  color: !isRead ? unreadHighlightColor : Colors.transparent,
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Align items vertically
                    children: [
                      // Leading: Profile Pic or Icon
                      (isMessageType && senderProfilePicUrl.isNotEmpty)
                          ? CircleAvatar(
                            radius: 22,
                            backgroundColor: themeColor.withOpacity(0.1),
                            backgroundImage: CachedNetworkImageProvider(
                              senderProfilePicUrl,
                            ),
                            onBackgroundImageError:
                                (_, __) {}, // Handle error silently for now
                          )
                          : CircleAvatar(
                            radius: 22,
                            backgroundColor: leadingIconColor.withOpacity(0.15),
                            child: Icon(
                              leadingIconData,
                              color: leadingIconColor,
                              size: 22,
                            ),
                          ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              senderName,
                              style: TextStyle(
                                fontWeight:
                                    !isRead ? FontWeight.bold : FontWeight.w600,
                                fontSize: 15,
                                color: primaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    !isRead
                                        ? primaryTextColor.withOpacity(0.85)
                                        : secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (timestamp != null)
                              Text(
                                _formatTimestamp(timestamp),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryTextColor.withOpacity(0.8),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (!isRead) // Unread indicator dot
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: themeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --- Notification Icon for AppBar (buildNotificationIcon) ---
Widget buildNotificationIcon(BuildContext context) {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final Color iconColor = isDarkMode ? Colors.white70 : Colors.black54;

  if (currentUser == null) {
    return IconButton(
      icon: Icon(Icons.notifications_none_outlined, color: iconColor, size: 26),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please log in to view notifications.")),
        );
      },
    );
  }

  return StreamBuilder<QuerySnapshot>(
    stream:
        FirebaseFirestore.instance
            .collection('notifications')
            .where('receiverId', isEqualTo: currentUser.uid)
            .where('isRead', isEqualTo: false)
            .snapshots(),
    builder: (context, snapshot) {
      int unreadCount = 0;
      if (snapshot.connectionState == ConnectionState.active &&
          snapshot.hasData) {
        unreadCount = snapshot.data!.docs.length;
      }

      return badges.Badge(
        position: badges.BadgePosition.topEnd(top: 6, end: 6),
        badgeContent: Text(
          unreadCount > 9 ? '9+' : unreadCount.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        showBadge: unreadCount > 0,
        badgeStyle: const badges.BadgeStyle(
          badgeColor: Colors.redAccent,
          padding: EdgeInsets.all(5.5),
          elevation: 0,
        ),
        child: IconButton(
          icon: Icon(
            Icons.notifications_none_outlined,
            color: iconColor,
            size: 26,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            );
          },
        ),
      );
    },
  );
}
