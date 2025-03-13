import 'package:flutter/material.dart';
import 'package:mad/features/Profile/profile_screen.dart';
import 'package:mad/features/home/screens/search_screen.dart';
import 'package:mad/features/home/screens/setting_screen.dart';
import 'package:provider/provider.dart';
import '/features/communities/communities_screen.dart';
import '/widgets/bottom_nav_bar.dart';
import '/features/posts/widgets/post_card.dart';
import '/providers/post_provider.dart';
import '/providers/auth_provider.dart';
import '/features/chat/screens/chat_screen.dart';
import '/features/posts/screens/create_post_screen.dart';

class HomeScreen extends StatefulWidget{
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  int _selectedIndex=0;
  // Pages for Bottom Navigation
  static final List<Widget> _pages = [
    FeedScreen(),
    CommunitiesScreen(),
    CreatePostScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index){
    setState(() {
      _selectedIndex=index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Campzy"),
        actions: [
          IconButton(
              onPressed: (){
                Navigator.push(context,MaterialPageRoute(builder: (context) => SearchScreen()));
              },
              icon: Icon(Icons.search)),
          IconButton(onPressed: (){}, icon: Icon(Icons.notifications)),
          IconButton(
            onPressed: (){
              Navigator.push(context,MaterialPageRoute(builder: (context) => SettingScreen()));},
            icon: Icon(Icons.menu)),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex, // Maintain state of pages
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<PostProvider>(context, listen: false).fetchPosts());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        if (postProvider.posts.isEmpty) {
          return Center(child: Text('No posts available'));
        }
        return ListView.builder(
          itemCount: postProvider.posts.length,
          itemBuilder: (context, index) {
            final post = postProvider.posts[index];
            return PostCard(post: post);
          },
        );
      },
    );
  }
}

