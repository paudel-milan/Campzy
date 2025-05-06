import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/post_model.dart';
import '../posts/widgets/post_card.dart';
import '../auth/screens/login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Color themeColor = Color(0xFF7851A9);

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,

      body: user == null
          ? _buildAnonymousProfile(context)
          : FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: themeColor));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("User data not found", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)));
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          return _buildUserProfile(context, userData, user.uid);
        },
      ),
    );
  }

  Widget _buildAnonymousProfile(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 50, backgroundColor: Colors.grey.shade300, child: Icon(Icons.person, size: 50, color: isDarkMode ? Colors.white : Colors.black)),
          SizedBox(height: 10),
          Text("Anonymous User", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
          Text("Login to access your profile", style: TextStyle(color: Colors.grey)),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: themeColor),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            child: Text("Login", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, Map<String, dynamic> userData, String uid) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Profile Picture
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade300,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: userData['profilePic'] ?? '',
                          placeholder: (context, url) => CircularProgressIndicator(color: themeColor),
                          errorWidget: (context, url, error) => Icon(Icons.person, size: 40, color: Colors.grey),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: themeColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: isDarkMode ? Colors.black : Colors.white, width: 1),
                        ),
                        child: Icon(Icons.add, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn("Posts", userData['postsCount']?.toString() ?? "0"),
                          _buildStatColumn("Followers", userData['followers']?.toString() ?? "0"),
                          _buildStatColumn("Following", userData['following']?.toString() ?? "0"),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EditProfileScreen(userData: userData)),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: isDarkMode ? Colors.grey[600]! : Colors.grey[400]!),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                              child: Text("Edit profile", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                            ),
                          ),
                          SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {
                              // TODO: Implement share profile functionality
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: isDarkMode ? Colors.grey[600]! : Colors.grey[400]!),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            ),
                            child: Icon(Icons.person_add_outlined, color: isDarkMode ? Colors.white : Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData['username'] ?? "No Username",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
                ),
                SizedBox(height: 2),
                Text(
                  userData['bio'] ?? "No bio available",
                  style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          Divider(height: 1, thickness: 0.5, color: isDarkMode ? Colors.grey[800] : Colors.grey[300]),
          // Posts Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "Posts",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDarkMode ? Colors.white : Colors.black),
            ),
          ),
          // User Posts List
          _buildUserPosts(uid),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
        Text(label, style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildUserPosts(String uid) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('posts').where('uid', isEqualTo: uid).orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: themeColor));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error fetching posts: ${snapshot.error}', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("No posts yet", style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
          );
        }
        return ListView.builder(
          shrinkWrap: true, // Keep this for the ListView to take only necessary space
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            PostModel post = PostModel(
              postId: doc['postId'],
              uid: doc['uid'],
              username: doc['username'],
              profilePicUrl: doc['profilePicUrl'],
              title: doc['title'],
              description: doc['description'],
              imageUrl: doc['imageUrl'],
              upvotes: doc['upvotes'] ?? 0,
              downvotes: doc['downvotes'] ?? 0,
              commentsCount: doc['commentsCount'] ?? 0,
              tag: doc['tag'],
              postType: doc['postType'],
              createdAt: doc['createdAt'],
            );
            return PostCard(post: post);
          },
        );
      },
    );
  }
}