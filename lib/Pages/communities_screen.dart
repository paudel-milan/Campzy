import 'package:flutter/material.dart';

class CommunitiesScreen extends StatefulWidget{
  @override
  _CommunitiesScreenState createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Communities"),
        centerTitle: true,
        backgroundColor: Colors.pink,
      ),
    );
  }
}