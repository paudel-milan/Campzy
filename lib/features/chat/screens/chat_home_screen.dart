import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class ChatHomeScreen extends StatelessWidget {
  const ChatHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: isDarkMode ? Colors.white : Colors.blue));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userDoc = users[index];
              final userData = userDoc.data() as Map<String, dynamic>;

              // Skip current user
              if (userDoc.id == currentUserId) return const SizedBox.shrink();

              // Fetch user data fields (including 'username' and 'profilePic')
              final name = userData.containsKey('username') ? userData['username'] : 'Unknown';
              final profilePic = userData.containsKey('profilePic') && userData['profilePic'] != null
                  ? userData['profilePic']
                  : 'https://www.gravatar.com/avatar/placeholder?d=mp';

              // You can replace the below placeholders with actual logic to get the last message
              const lastMessage = "This is the last message"; // Placeholder
              final lastMessageTime = DateTime.now(); // Placeholder for timestamp

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        peerId: userDoc.id,
                        peerName: name,
                        peerAvatarUrl: profilePic,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.white, // Darker background for dark mode
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.1), // Adjusted shadow for dark mode
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(profilePic),
                        backgroundColor: Colors.grey[isDarkMode ? 700 : 200], // Darker grey for dark mode
                      ),
                      const SizedBox(width: 10),
                      // User Info Column
                      Expanded( // Use Expanded to prevent overflow
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User Name
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black, // Text color
                              ),
                            ),
                            const SizedBox(height: 5),
                            // Last message
                            Text(
                              lastMessage,
                              style: TextStyle(
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600], // Adjusted text color
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis, // Handle long messages
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Last message timestamp
                      Text(
                        "${lastMessageTime.hour}:${lastMessageTime.minute < 10 ? '0${lastMessageTime.minute}' : lastMessageTime.minute}",
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                          fontSize: 12,
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