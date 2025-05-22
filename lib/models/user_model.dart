import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String username; // From your original version
  final String email;
  final String bio;
  final String profilePic;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.username,
    required this.email,
    required this.bio,
    required this.profilePic,
    required this.createdAt,
  });

  // Firestore → AppUser
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      username: map['username'] ?? map['name'] ?? '', // Support both keys
      email: map['email'] ?? '',
      bio: map['bio'] ?? '',
      profilePic: map['profilePic'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // AppUser → Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'bio': bio,
      'profilePic': profilePic,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
