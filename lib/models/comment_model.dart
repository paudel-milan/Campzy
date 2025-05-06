import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String uid;
  final String username;
  final String profilePicUrl;
  final String text;
  final Timestamp createdAt;

  CommentModel({
    required this.uid,
    required this.username,
    required this.profilePicUrl,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> data) {
    return CommentModel(
      uid: data['uid'],
      username: data['username'],
      profilePicUrl: data['profilePicUrl'],
      text: data['text'],
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'profilePicUrl': profilePicUrl,
      'text': text,
      'createdAt': createdAt,
    };
  }
}
