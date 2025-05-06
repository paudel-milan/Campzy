import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String uid; // User ID of creator
  final String username;
  final String profilePicUrl;

  final String title;
  final String description;
  final String imageUrl;

  final int upvotes;
  final int downvotes;
  final int commentsCount;

  final String tag; // Like "Technology", "College", etc.
  final String postType; // 'text', 'image', etc.

  final Timestamp createdAt;

  PostModel({
    required this.postId,
    required this.uid,
    required this.username,
    required this.profilePicUrl,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.upvotes,
    required this.downvotes,
    required this.commentsCount,
    required this.tag,
    required this.postType,
    required this.createdAt,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PostModel(
      postId: doc.id,
      uid: data['uid'] ?? '',
      username: data['username'] ?? 'Anonymous',
      profilePicUrl: data['profilePicUrl'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      upvotes: data['upvotes'] ?? 0,
      downvotes: data['downvotes'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      tag: data['tag'] ?? 'general',
      postType: data['postType'] ?? 'text',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'profilePicUrl': profilePicUrl,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'commentsCount': commentsCount,
      'tag': tag,
      'postType': postType,
      'createdAt': createdAt,
    };
  }
}
