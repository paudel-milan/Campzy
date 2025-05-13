import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For better image handling
import 'package:intl/intl.dart'; // For formatting timestamp
import 'chat_screen.dart';

class ChatHomeScreen extends StatelessWidget {
  const ChatHomeScreen({super.key});

  final Color themeColor = const Color(0xFF7851A9); // Consistent theme color

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? Colors.black : Colors.grey[100]!;
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor =
        isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final Color subtleTextColor =
        isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

    if (currentUserId == null) {
      // Handle case where user is not logged in, though typically caught earlier
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Text(
            "Please log in to view chats.",
            style: TextStyle(color: textColor),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      // AppBar can be added here if needed, consistent with HomeScreen's AppBar logic
      // appBar: AppBar(
      //   title: Text("Chats", style: GoogleFonts.lato(...)),
      //   backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      //   elevation: 1,
      // ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                // .orderBy('lastActivity', descending: true) // Example: if you track user activity for sorting
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: themeColor));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading users.",
                style: TextStyle(color: textColor),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No users found.",
                style: TextStyle(color: textColor),
              ),
            );
          }

          final usersDocs =
              snapshot.data!.docs
                  .where((doc) => doc.id != currentUserId)
                  .toList();

          if (usersDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 60,
                    color: subtleTextColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No one to chat with yet",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Find users and start a conversation!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: subtleTextColor),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: usersDocs.length,
            itemBuilder: (context, index) {
              final userDoc = usersDocs[index];
              final userData = userDoc.data() as Map<String, dynamic>;

              final String name = userData['username'] ?? 'Unknown User';
              final String profilePicUrl =
                  userData['profilePic'] ?? ''; // Default to empty string

              // --- Placeholder for Last Message Logic ---
              // In a real app, you'd fetch this from a 'chats' or 'messages' collection
              // based on the conversation between currentUserId and userDoc.id
              const String lastMessage =
                  "Tap to start a conversation!"; // Placeholder
              final DateTime lastMessageTime = DateTime.now().subtract(
                Duration(minutes: index * 5),
              ); // Dynamic placeholder time
              // bool hasUnreadMessages = index % 3 == 0; // Placeholder for unread indicator
              // --- End Placeholder ---

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ChatScreen(
                            peerId: userDoc.id,
                            peerName: name,
                            peerAvatarUrl: profilePicUrl,
                          ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 12,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDarkMode
                                ? Colors.black.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: themeColor.withOpacity(0.1),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage:
                              profilePicUrl.isNotEmpty
                                  ? CachedNetworkImageProvider(profilePicUrl)
                                  : null,
                          child:
                              profilePicUrl.isEmpty
                                  ? Icon(
                                    Icons.person,
                                    size: 30,
                                    color: themeColor.withOpacity(0.8),
                                  )
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.w600, // Semi-bold for name
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lastMessage,
                              style: TextStyle(
                                color: subtleTextColor,
                                fontSize: 14,
                                // fontWeight: hasUnreadMessages ? FontWeight.bold : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat.jm().format(
                              lastMessageTime,
                            ), // e.g., 5:08 PM
                            style: TextStyle(
                              color: subtleTextColor,
                              fontSize: 12,
                            ),
                          ),
                          // SizedBox(height: 4),
                          // if (hasUnreadMessages)
                          //   Container(
                          //     padding: EdgeInsets.all(5),
                          //     decoration: BoxDecoration(
                          //       color: themeColor,
                          //       shape: BoxShape.circle,
                          //     ),
                          //     child: Text("1", style: TextStyle(color: Colors.white, fontSize: 10)), // Placeholder unread count
                          //   ),
                        ],
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
