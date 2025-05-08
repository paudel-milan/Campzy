import 'package:flutter/material.dart';
import 'package:mad/models/community_model.dart';
import 'package:mad/features/communities/services/community_service.dart';

class CommunityProvider with ChangeNotifier {
  final CommunityService _communityService;
  List<Community> _communities = [];
  bool _isLoading = false;

  CommunityProvider(this._communityService);

  List<Community> get communities => _communities;
  bool get isLoading => _isLoading;

  Future<void> fetchCommunities() async {
    _isLoading = true;
    notifyListeners();

    try {
      _communities = await _communityService.getCommunities().first;
    } catch (e) {
      debugPrint('Error fetching communities: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> joinCommunity(String communityId, String userId) async {
    try {
      await _communityService.joinCommunity(communityId, userId);
      await fetchCommunities(); // Refresh the list
    } catch (e) {
      debugPrint('Error joining community: $e');
    }
  }

  Future<void> leaveCommunity(String communityId, String userId) async {
    try {
      await _communityService.leaveCommunity(communityId, userId);
      await fetchCommunities(); // Refresh the list
    } catch (e) {
      debugPrint('Error leaving community: $e');
    }
  }

  Future<void> createCommunity({
    required String name,
    required String description,
    required String creatorId,
    String? imageUrl,
  }) async {
    try {
      await _communityService.createCommunity(
        name: name,
        description: description,
        creatorId: creatorId,
        imageUrl: imageUrl,
      );
      await fetchCommunities(); // Refresh the list
    } catch (e) {
      debugPrint('Error creating community: $e');
      rethrow;
    }
  }
}