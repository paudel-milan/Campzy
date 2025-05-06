import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/post_model.dart';


class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> uploadPost({
    required String title,
    required String description,
    required String imageUrl, // Can be empty if text-only post
    required String tag,
    required String postType, // 'text', 'image', etc.
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final postDoc = _firestore.collection('posts').doc(); // Auto-generate ID

      final post = PostModel(
        postId: postDoc.id,
        uid: user.uid,
        username: user.displayName ?? 'Anonymous',
        profilePicUrl: user.photoURL ?? '',
        title: title,
        description: description,
        imageUrl: imageUrl,
        upvotes: 0,
        downvotes: 0,
        commentsCount: 0,
        tag: tag,
        postType: postType,
        createdAt: Timestamp.now(),
      );

      await postDoc.set(post.toMap());
      print("✅ Post uploaded successfully.");
    } catch (e) {
      print("❌ Failed to upload post: $e");
    }
  }
}
