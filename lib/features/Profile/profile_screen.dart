import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart'; // For AppBar title styling

import '../../models/post_model.dart'; // Assuming this path is correct
import '../posts/widgets/post_card.dart'; // Assuming this path is correct
import '../auth/screens/login_screen.dart'; // Assuming this path is correct
import 'edit_profile_screen.dart'; // Assuming this path is correct
// import '../home/screens/setting_screen.dart'; // Assuming you have a SettingScreen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Color themeColor = const Color(0xFF7851A9); // Deep Purple

  Future<void> _signOut() async {
    await _auth.signOut();
    if (mounted) { // Check if the widget is still in the tree
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    // Define colors for UI consistency
    final Color scaffoldBackgroundColor = isDarkMode ? Colors.black : Colors.grey[100]!;
    final Color appBarBackgroundColor = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final Color appBarTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final Color appBarIconColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: appBarBackgroundColor,
        elevation: 0.5, // Subtle elevation for a modern look
        title: Text(
          user != null ? "My Profile" : "Profile", // Dynamic title
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: appBarTextColor,
          ),
        ),
        iconTheme: IconThemeData(color: appBarIconColor), // For back button if navigated here
        actions: user != null
            ? [
                // IconButton(
                //   icon: Icon(Icons.settings_outlined, color: appBarIconColor),
                //   onPressed: () {
                //     // TODO: Navigate to a SettingsScreen
                //     // Navigator.push(context, MaterialPageRoute(builder: (context) => SettingScreen()));
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       const SnackBar(content: Text('Settings (Not implemented yet)')),
                //     );
                //   },
                //   tooltip: 'Settings',
                // ),
                IconButton(
                  icon: Icon(Icons.logout_rounded, color: appBarIconColor),
                  onPressed: _signOut,
                  tooltip: 'Logout',
                ),
                const SizedBox(width: 8), // Give some padding to the last icon
              ]
            : [], // No actions for anonymous user in this example
      ),
      body: user == null
          ? _buildAnonymousProfile(context)
          : FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(user.uid).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: themeColor),
                  );
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return _buildUserDataNotFound(context, user.uid);
                }
                var userData = snapshot.data!.data() as Map<String, dynamic>;
                return _buildUserProfile(context, userData, user.uid);
              },
            ),
    );
  }

  Widget _buildUserDataNotFound(BuildContext context, String uid) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final Color secondaryTextColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;


    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0), // Increased padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_outlined, color: themeColor.withOpacity(0.7), size: 70), // More relevant icon
            const SizedBox(height: 20),
            Text(
              "Profile Data Not Found",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20, // Slightly larger
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "We couldn't retrieve your profile details at this moment. This might be due to a new account setup or a temporary network issue.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 15,
                height: 1.4, // Improved line spacing
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon( // Added icon to button
              icon: const Icon(Icons.logout, color: Colors.white, size: 18),
              label: const Text("Logout & Try Again", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                 shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _signOut, // Re-use the sign out method
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnonymousProfile(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final Color secondaryTextColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
    final Color iconBgColor = isDarkMode ? Colors.grey[850]! : Colors.grey.shade200;
    final Color iconItselfColor = isDarkMode ? themeColor.withOpacity(0.8) : themeColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: iconBgColor,
              child: Icon(
                Icons.no_accounts_outlined, // More specific icon
                size: 60,
                color: iconItselfColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Access Your Profile",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Please log in or sign up to view your profile, share posts, and connect with our community.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text("Login / Sign Up", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(
    BuildContext context,
    Map<String, dynamic> userData,
    String uid,
  ) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color cardBackgroundColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final Color secondaryTextColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Ensures children take full width if needed
        children: [
          // Profile Header Card
          Container(
            margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0), // Adjusted top margin
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: themeColor.withOpacity(0.2),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey.shade300,
                        backgroundImage: (userData['profilePic'] != null && (userData['profilePic'] as String).isNotEmpty)
                          ? CachedNetworkImageProvider(userData['profilePic'])
                          : null,
                        child: (userData['profilePic'] == null || (userData['profilePic'] as String).isEmpty)
                          ? Icon(Icons.person_outline, size: 50, color: themeColor)
                          : null,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userData['username'] ?? "Username",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (userData['fullName'] != null && (userData['fullName'] as String).isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              userData['fullName'],
                              style: TextStyle(
                                fontSize: 14,
                                color: secondaryTextColor,
                              ),
                               maxLines: 1,
                               overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            userData['bio']?.isNotEmpty == true ? userData['bio'] : "No bio yet. Tap 'Edit Profile' to add one!",
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryTextColor,
                              fontStyle: userData['bio']?.isNotEmpty == true ? FontStyle.normal : FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn("Posts", userData['postsCount']?.toString() ?? "0", isDarkMode),
                    _buildStatColumn("Followers", userData['followers']?.toString() ?? "0", isDarkMode),
                    _buildStatColumn("Following", userData['following']?.toString() ?? "0", isDarkMode),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white),
                        label: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(userData: userData),
                            ),
                          ).then((value) { // Check if data was updated
                            if (value == true && mounted) { // `true` indicates profile was updated
                              setState(() {}); // Re-fetch or rebuild to show updated data
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: Icon(Icons.share_outlined, color: themeColor),
                      onPressed: () {
                        // TODO: Implement share profile functionality (e.g., using share_plus package)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share profile (Not implemented yet)')),
                        );
                      },
                       tooltip: 'Share Profile',
                       style: IconButton.styleFrom(
                        backgroundColor: themeColor.withOpacity(0.1),
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Posts Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(Icons.grid_on_rounded, color: isDarkMode ? Colors.grey[400] : Colors.grey[700]), // Changed icon
                const SizedBox(width: 10),
                Text(
                  "My Posts",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: primaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 20,
            endIndent: 20,
            color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
          ),
          const SizedBox(height: 8),
          _buildUserPosts(uid),
          const SizedBox(height: 20), // Add some padding at the bottom
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, bool isDarkMode) {
    final Color valueColor = isDarkMode ? Colors.white : Colors.black87;
    final Color labelColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: labelColor, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildUserPosts(String uid) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('posts')
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding( // Less intrusive loader for post list
            padding: const EdgeInsets.all(30.0),
            child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: themeColor))),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error fetching posts: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(color: isDarkMode ? Colors.red[300] : Colors.red[700]),
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.dynamic_feed_outlined, size: 50, color: isDarkMode ? Colors.grey[600] : Colors.grey[400]),
                  const SizedBox(height: 10),
                  Text(
                    "No Posts Yet",
                    style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[500] : Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Looks like you haven't shared anything. Create your first post!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isDarkMode ? Colors.grey[600] : Colors.grey[500]),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot doc = snapshot.data!.docs[index];
            PostModel post = PostModel.fromFirestore(doc);
            return PostCard(post: post);
          },
        );
      },
    );
  }
}

// Ensure your PostModel.fromFirestore can handle an optional DocumentSnapshot for the ID:
// factory PostModel.fromFirestore(Map<String, dynamic> data, {DocumentSnapshot? docSnapshot}) {
//   return PostModel(
//     postId: docSnapshot?.id ?? data['postId'] ?? '', // Prefer docSnapshot.id
//     // ... other fields
//   );
// }