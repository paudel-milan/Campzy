import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/post_model.dart'; // Import PostModel

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Fetch posts with pagination and convert to PostModel
  Future<List<PostModel>> getPosts({DocumentSnapshot? lastDoc, int limit = 10}) async {
    Query query = _firestore.collection('posts').orderBy('createdAt', descending: true).limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    QuerySnapshot snapshot = await query.get();

    // 🔹 Convert Firestore Documents into PostModel list
    return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
  }


  // ✅ Create a new post
  Future<void> createPost({
    required String text,
    required String authorId,
    required String username,
  }) async {
    try {
      await _firestore.collection('posts').add({
        'authorId': authorId,
        'username': username,
        'content': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error creating post: $e");
    }
  }
}
