import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String authorId;
  final String title;
  final String description;
  final String imageUrl;
  final Timestamp createdAt;

  PostModel({
    required this.authorId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
  });

  // ✅ Add this method to properly parse Firestore documents
  factory PostModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      authorId: data['authorId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
