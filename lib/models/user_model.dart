class AppUser {
  final String uid;
  final String username;
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

  // Convert Firestore document to AppUser
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      username: map['username'],
      email: map['email'],
      bio: map['bio'] ?? '',
      profilePic: map['profilePic'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  // Convert AppUser to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'bio': bio,
      'profilePic': profilePic,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
