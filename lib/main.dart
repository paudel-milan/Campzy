import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart'; // Import the navigation bar
import './Pages/home_screen.dart';
import './Pages/communities_screen.dart';
import './Pages/create_post_screen.dart';
import './Pages/chat_screen.dart';
import './Pages/profile_screen.dart';


void main(){
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campzy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(), // Start from MainScreen
    );
  }
}

class MainScreen extends  StatefulWidget{
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>{
  int _selectedIndex=0;
  final List<Widget> _pages=[
    HomeScreen(),
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _selectedIndex, onTap: _onItemTapped,),
    );
  }

}