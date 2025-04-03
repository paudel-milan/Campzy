import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'chatbot_screen.dart';

class ChatHomeScreen extends StatelessWidget {
  final List<Map<String, String>> onlineUsers = [
    {'name': 'Alice'},
    {'name': 'Bob'},
    {'name': 'Charlie'},
    {'name': 'Manoj'},
    {'name': 'Rishit'},
    {'name': 'Milan'},
  ];

  final List<Map<String, String>> allUsers = [
    {'name': 'Manoj'},
    {'name': 'Rishit'},
    {'name': 'Milan'},
    {'name': 'Alice'},
    {'name': 'Bob'},
    {'name': 'Ram'},
    {'name': 'Krishna'},
    {'name': 'Radhe Radhe'},
    {'name': 'Charlie'},
    {'name': 'David'},
    {'name': 'Emma'},
    {'name': 'Frank'},
    {'name': 'Grace'},
    {'name': 'Charlie'},
    {'name': 'Ali'},
  ];

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? Colors.black : Color(0xFFFFE4E1),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            _buildChatbotTile(context, isDarkMode),
            _buildOnlineUserList(context, isDarkMode),
            Expanded(child: _buildChatList(context, isDarkMode)),
          ],
        ),
      ),
    );
  }

  Widget _buildChatbotTile(BuildContext context, bool isDarkMode) {
    return ListTile(
      tileColor: isDarkMode ? Colors.grey[900] : Colors.white,
      leading: CircleAvatar(
        backgroundColor: isDarkMode ? Colors.blue[700] : Colors.blueAccent,
        child: Icon(Icons.smart_toy, color: Colors.white),
      ),
      title: Text(
        "Campzy AI Chatbot",
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        "Ask me anything!",
        style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.black54),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatbotScreen()), // Navigate to ChatbotScreen
        );
      },
    );
  }


  Widget _buildOnlineUserList(BuildContext context, bool isDarkMode) {
    return Container(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: onlineUsers.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(user: onlineUsers[index]),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
                        radius: 30,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: isDarkMode ? Colors.white : Color(0xFF7851A9),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDarkMode ? Colors.black : Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    onlineUsers[index]['name']!,
                    style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white : Colors.black),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatList(BuildContext context, bool isDarkMode) {
    return ListView.builder(
      itemCount: allUsers.length,
      itemBuilder: (context, index) {
        return ListTile(
          tileColor: isDarkMode ? Colors.grey[900] : Colors.white,
          leading: CircleAvatar(
            backgroundColor: isDarkMode ? Colors.grey[700] : Color(0xFF7851A9),
            child: Icon(Icons.person, color: isDarkMode ? Colors.white : Colors.white),
          ),
          title: Text(
            allUsers[index]['name']!,
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          subtitle: Text(
            "Tap to chat",
            style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.black54),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen(user: allUsers[index]))
            );
          },
        );
      },
    );
  }
}
