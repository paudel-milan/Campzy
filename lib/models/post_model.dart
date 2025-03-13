import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String authorId;
  final String title;
  final String description;
  final String imageUrl;
  final Timestamp createdAt;
  final DocumentSnapshot? docSnapshot; // 🔥 Store Firestore document reference

  PostModel({
    required this.authorId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
    this.docSnapshot, // Optional for pagination
  });

  // ✅ Convert Firestore document to PostModel
  factory PostModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      authorId: data['authorId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      docSnapshot: doc, // 🔥 Save document snapshot for pagination
    );
  }

  // ✅ Copy method to create a new instance with updated values
  PostModel copyWith({DocumentSnapshot? docSnapshot}) {
    return PostModel(
      authorId: authorId,
      title: title,
      description: description,
      imageUrl: imageUrl,
      createdAt: createdAt,
      docSnapshot: docSnapshot ?? this.docSnapshot,
    );
  }
}
