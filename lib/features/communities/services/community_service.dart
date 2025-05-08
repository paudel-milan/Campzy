import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mad/models/community_model.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new community
  Future<void> createCommunity({
    required String name,
    required String description,
    required String creatorId,
    String? imageUrl,
  }) async {
    try {
      final communityRef = _firestore.collection('communities').doc();

      final community = Community(
        id: communityRef.id,
        name: name,
        description: description,
        creatorId: creatorId,
        members: [creatorId],
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await communityRef.set(community.toMap());
    } catch (e) {
      throw Exception('Failed to create community: $e');
    }
  }

  // // Get all communities
  Stream<List<Community>> getCommunities() {
    return _firestore
        .collection('communities')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Community.fromMap(doc.data()))
          .toList();
    });
  }

  // Join a community
  Future<void> joinCommunity(String communityId, String userId) async {
    await _firestore.collection('communities').doc(communityId).update({
      'members': FieldValue.arrayUnion([userId]),
    });
  }

  // Leave a community
  Future<void> leaveCommunity(String communityId, String userId) async {
    await _firestore.collection('communities').doc(communityId).update({
      'members': FieldValue.arrayRemove([userId]),
    });
  }
}
