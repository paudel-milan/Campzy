import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/post_model.dart';

class PostProvider with ChangeNotifier {
  List<PostModel> _posts = [];

  List<PostModel> get posts => _posts;

  Future<void> fetchPosts() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('posts').get();
      _posts =
          snapshot.docs.map((doc) => PostModel.fromDocument(doc)).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

}