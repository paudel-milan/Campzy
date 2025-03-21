import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String title;
  final String description;
  final String imageUrl;
  final String profilePicUrl;
  final String username;
  final int upvotes;
  final int downvotes;
  final int commentsCount;
  final Timestamp createdAt;

  PostModel({
    required this.postId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.profilePicUrl,
    required this.username,
    required this.upvotes,
    required this.downvotes,
    required this.commentsCount,
    required this.createdAt,
  });

  // Factory method to create PostModel from Firestore data
  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PostModel(
      postId: doc.id,
      // Always use Firestore's document ID
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      profilePicUrl: data['profilePicUrl'] ?? '',
      username: data['username'] ?? 'Anonymous',
      // Fallback value
      upvotes: (data['upvotes'] as int?) ?? 0,
      downvotes: (data['downvotes'] as int?) ?? 0,
      commentsCount: (data['commentsCount'] as int?) ?? 0,
      createdAt: data['createdAt'] is Timestamp
          ? data['createdAt']
          : Timestamp.now(), // Handle null or incorrect format
    );
  }
}

