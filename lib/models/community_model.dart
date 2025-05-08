import 'package:cloud_firestore/cloud_firestore.dart';

class Community {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final List<String> members;
  final String? imageUrl;
  final DateTime createdAt;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.members,
    this.imageUrl,
    required this.createdAt,
  });

  // Add fromMap and toMap methods
  factory Community.fromMap(Map<String, dynamic> map) {
    return Community(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      creatorId: map['creatorId'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'members': members,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}