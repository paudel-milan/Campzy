import 'package:flutter/material.dart';

class CommunitiesScreen extends StatelessWidget {
  final List<Map<String, String>> departments = [
    {'name': 'Computer Science', 'description': 'Discussion and resources for CSE students.'},
    {'name': 'Electronics & Communication', 'description': 'Explore the world of ECE with peers.'},
    {'name': 'Mechanical Engineering', 'description': 'Join discussions on mechanical innovations.'},
    {'name': 'Civil Engineering', 'description': 'Collaborate on structural designs and projects.'},
    {'name': 'Electrical Engineering', 'description': 'Talk about circuits, power systems, and more.'},
    {'name': 'Artificial Intelligence & Data Science', 'description': 'Stay updated on AI and DS trends.'},
  ];

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        color: isDarkMode ? Colors.black : Color(0xFFFFE4E1), // Adapts to theme
        child: ListView.builder(
          itemCount: departments.length,
          itemBuilder: (context, index) {
            return Card(
              color: isDarkMode ? Colors.grey[850] : Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isDarkMode ? Colors.grey[700] : Color(0xFF7851A9),
                  child: Icon(Icons.school, color: isDarkMode ? Colors.white : Colors.white),
                ),
                title: Text(
                  departments[index]['name']!,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  departments[index]['description']!,
                  style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.black54),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Opening ${departments[index]['name']}...")),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
