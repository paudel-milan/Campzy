import 'package:flutter/material.dart';

class CreatePostScreen extends StatefulWidget{
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Post"),
        centerTitle: true,
        backgroundColor: Colors.pink,
      ),
    );
  }
}