import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mad/features/Profile/profile_screen.dart';
import 'package:mad/features/home/screens/search_screen.dart';
import 'package:mad/features/home/screens/setting_screen.dart';
import 'package:provider/provider.dart';
import '../../notifications/notification_screen.dart'; // Assuming correct path
import '/features/communities/communities_screen.dart'; // Assuming correct path
import '/widgets/bottom_nav_bar.dart'; // Your BottomNavBar path
import '/features/posts/widgets/post_card.dart';
import '/providers/post_provider.dart'; // Your PostProvider path
// import '/providers/auth_provider.dart'; // Not used in this snippet
import '/features/chat/screens/chat_home_screen.dart'; // Assuming correct path
import '/features/posts/screens/create_post_screen.dart'; // Assuming correct path
import '/features/posts/screens/post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final Color themeColor = const Color(0xFF7851A9); // Consistent theme color

  static const List<String> _pageTitles = [
    "Campzy",
    "Communities",
    "Create Post",
    "Chats",
    "Profile",
  ];

  static final List<Widget> _pages = [
    const FeedScreen(),
    const CommunitiesScreen(),
    const CreatePostScreen(),
    const ChatHomeScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color appBarColor = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final Color iconColor = isDarkMode ? Colors.white70 : Colors.black54;
    final Color titleColor = themeColor;

    // ProfileScreen (index 4) and CreatePostScreen (index 2) might have their own AppBars or no AppBar.
    bool showMainAppBar = _selectedIndex != 4 && _selectedIndex != 2;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
      appBar: showMainAppBar
          ? AppBar(
              elevation: isDarkMode ? 0.5 : 1.0,
              backgroundColor: appBarColor,
              title: Text(
                _selectedIndex == 0 ? "Campzy" : _pageTitles[_selectedIndex],
                style: _selectedIndex == 0
                    ? GoogleFonts.lobster(
                        fontSize: 28,
                        color: titleColor,
                        fontWeight: FontWeight.normal,
                      )
                    : GoogleFonts.lato(
                        fontSize: 20,
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                    ),
              ),
              iconTheme: IconThemeData(color: iconColor),
              actionsIconTheme: IconThemeData(color: iconColor, size: 24),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SearchScreen()),
                    );
                  },
                  icon: const Icon(Icons.search_outlined),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationScreen()),
                    );
                  },
                ),
                if (_selectedIndex != 4) // Don't show main settings/menu on ProfileScreen
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingScreen()),
                      );
                    },
                    icon: const Icon(Icons.menu_rounded),
                  ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Your BottomNavBar has hardcoded colors.
        // To make it theme-aware, you'd modify your BottomNavBar widget itself.
        // For example, in your _BottomNavBarState:
        // selectedItemColor: Theme.of(context).colorScheme.primary, // Or your themeColor
        // unselectedItemColor: Theme.of(context).unselectedWidgetColor,
      ),
    );
  }
}

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});
  final Color themeColor = const Color(0xFF7851A9);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        if (postProvider.posts.isEmpty) {
          // This could be an initial loading state or genuinely no posts.
          // Your PostProvider listens in real-time, so this will update.
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 // Show a progress indicator while posts are empty,
                 // as it might be the initial loading phase.
                CircularProgressIndicator(color: themeColor),
                const SizedBox(height: 20),
                Text(
                  "Loading posts or feed is empty...",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                 Text(
                  "Pull down to refresh if needed.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: themeColor,
          backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
          onRefresh: () async {
            // Re-trigger the listener in PostProvider.
            // This ensures the stream subscription is active and can act as a manual refresh.
            Provider.of<PostProvider>(context, listen: false).listenToPosts();
            // Add a small delay for UX if needed, though the listener should update quickly.
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            itemCount: postProvider.posts.length,
            itemBuilder: (context, index) {
              final post = postProvider.posts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostScreen(post: post),
                    ),
                  );
                },
                child: PostCard(post: post),
              );
            },
          ),
        );
      },
    );
  }
}