import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/post_model.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<PostModel>> getPosts() async {
    QuerySnapshot snapshot = await _firestore.collection('posts').get();
    return snapshot.docs.map((doc) => PostModel.fromDocument(doc)).toList();
  }
}
