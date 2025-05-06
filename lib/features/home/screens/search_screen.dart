import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = "";
  int selectedIndex = 0; // 0 for Posts, 1 for Users

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: "Search posts or users...",
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          // Tabs for switching between Posts and Users
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTabButton("Posts", 0),
              _buildTabButton("Users", 1),
            ],
          ),
          Expanded(
            child: selectedIndex == 0
                ? _buildPostResults()
                : _buildUserResults(),
          ),
        ],
      ),
    );
  }

  // 🔹 Tab Button
  Widget _buildTabButton(String text, int index) {
    return TextButton(
      onPressed: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
          color: selectedIndex == index ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }

  // 🔹 Search Posts
  Widget _buildPostResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('title', isGreaterThanOrEqualTo: searchQuery)
          .where('title', isLessThan: searchQuery + 'z')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        var posts = snapshot.data!.docs;
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            var post = posts[index];
            return ListTile(
              title: Text(post['title']),
              subtitle: Text(post['description']),
              onTap: () {
                // Navigate to Post Detail Page (Implement this)
              },
            );
          },
        );
      },
    );
  }

  // 🔹 Search Users
  Widget _buildUserResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: searchQuery)
          .where('username', isLessThan: searchQuery + '\uf8ff') // Range query for case-insensitive search
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        var users = snapshot.data!.docs;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            var user = users[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user['profilePic'] ?? ""),
              ),
              title: Text(user['username']),
              subtitle: Text(user['bio'] ?? 'No bio available'),
              onTap: () {
                // Navigate to User Profile Page (Implement this)
              },
            );
          },
        );
      },
    );
  }
}
