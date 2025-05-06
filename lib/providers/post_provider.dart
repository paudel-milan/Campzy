import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/post_model.dart';

class PostProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<PostModel> _posts = [];
  StreamSubscription? _postSubscription; // ✅ Listen to Firestore changes

  List<PostModel> get posts => _posts;

  PostProvider() {
    listenToPosts(); // ✅ Start real-time listener on initialization
  }

  /// ✅ Listen for real-time updates (automatically handles delete)
  void listenToPosts() {
    _postSubscription?.cancel(); // Prevent multiple listeners

    _postSubscription = _firestore.collection('posts').orderBy('createdAt', descending: true).snapshots().listen(
          (snapshot) {
        _posts = snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
        notifyListeners(); // ✅ Update UI when Firestore changes
      },
      onError: (error) {
        print('❌ Error listening to posts: $error');
      },
    );
  }

  /// ✅ Add a new post to Firestore
  Future<void> createPost({required String content, required String uid}) async {
    try {
      final newPost = {
        'content': content,
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('posts').add(newPost);
      print("✅ Post created successfully.");
    } catch (e) {
      print('❌ Error creating post: $e');
    }
  }

  /// ✅ Delete post from Firestore
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      print('❌ Error deleting post: $e');
    }
  }

  /// ✅ Dispose listener when provider is destroyed
  @override
  void dispose() {
    _postSubscription?.cancel();
    super.dispose();
  }
}
