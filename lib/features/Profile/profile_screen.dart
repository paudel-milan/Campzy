import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mad/features/Profile/about.dart';
import '../auth/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: textTheme.titleLarge),
        backgroundColor: isDarkMode ? Colors.black : Colors.blue,
        actions: [
          if (user != null)
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
        ],
      ),
      body: user == null
          ? _buildAnonymousProfile(context, textTheme, isDarkMode)
          : FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("User data not found", style: textTheme.bodyLarge));
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          return _buildUserProfile(context, userData, textTheme, isDarkMode);
        },
      ),
    );
  }

  /// Anonymous User Profile
  Widget _buildAnonymousProfile(BuildContext context, TextTheme textTheme, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/anonymous.png'),
          ),
          SizedBox(height: 10),
          Text("Anonymous User", style: textTheme.titleLarge),
          Text("Login to access your profile", style: textTheme.bodyMedium),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text("Login"),
          ),
        ],
      ),
    );
  }

  /// Logged-in User Profile (Reddit-style)
  Widget _buildUserProfile(BuildContext context, Map<String, dynamic> userData, TextTheme textTheme, bool isDarkMode) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Banner Section (like Reddit)
          Stack(
            children: [
              Container(
                height: 120,
                color: isDarkMode ? Colors.grey[900] : Colors.blueAccent,
              ),
              Positioned(
                bottom: -30,
                left: 20,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: userData['profilePic'] ?? '',
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          Image.asset('assets/default_avatar.png', fit: BoxFit.cover),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 40),

          // User Info
          Text(userData['name'] ?? "No Name", style: textTheme.titleLarge),
          Text(userData['email'] ?? "No Email", style: textTheme.bodyMedium),

          SizedBox(height: 10),
          Divider(color: isDarkMode ? Colors.white24 : Colors.black12),

          // Karma & Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard("Posts", userData['postsCount']?.toString() ?? "0", isDarkMode),
              _buildStatCard("Followers", userData['followers']?.toString() ?? "0", isDarkMode),
              _buildStatCard("Following", userData['following']?.toString() ?? "0", isDarkMode),
            ],
          ),

          SizedBox(height: 20),
          Divider(color: isDarkMode ? Colors.white24 : Colors.black12),

          // Settings & About
          ListTile(
            leading: Icon(Icons.settings, color: isDarkMode ? Colors.white : Colors.black),
            title: Text("Settings", style: textTheme.bodyLarge),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.info_outline, color: isDarkMode ? Colors.white : Colors.black),
            title: Text("About", style: textTheme.bodyLarge),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute( builder: (context) => AboutPage(),),);
            },
          ),
        ],
      ),
    );
  }

  /// User Stats Card (Posts, Followers, Following)
  Widget _buildStatCard(String label, String value, bool isDarkMode) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
      ],
    );
  }
}