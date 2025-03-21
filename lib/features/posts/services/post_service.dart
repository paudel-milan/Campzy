import 'package:cloud_firestore/cloud_firestore.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Fetch posts with pagination (ensuring sorting by createdAt)
  Future<List<DocumentSnapshot>> getPosts({DocumentSnapshot? lastDoc, int limit = 10}) async {
    Query query = _firestore.collection('posts').orderBy('createdAt', descending: true).limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    QuerySnapshot snapshot = await query.get();
    return snapshot.docs;
  }

  // ✅ Create a new post with proper field names
  Future<void> createPost({
    required String text,
    required String authorId,
    required String username,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('posts').add({
        'authorId': authorId,
        'username': username,
        'description': text, // ✅ Ensure consistency with Firestore fields
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ✅ Ensure `createdAt` is set properly
      await docRef.set({'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    } catch (e) {
      print("Error creating post: $e");
    }
  }
}
