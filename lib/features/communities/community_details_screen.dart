// lib/features/communities/community_details_screen.dart
import 'package:flutter/material.dart';
import 'package:mad/models/community_model.dart';
// For a more realistic member avatar, you might fetch user data.
// import 'package:cloud_firestore/cloud_firestore.dart'; // Example

class CommunityDetailsScreen extends StatelessWidget {
  final Community community;

  const CommunityDetailsScreen({super.key, required this.community});

  // Placeholder for fetching user data - replace with your actual service
  Future<Map<String, dynamic>?> _fetchUserDetails(String userId) async {
    // Example:
    // try {
    //   final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    //   if (doc.exists) return {'name': doc.data()?['username'], 'avatarUrl': doc.data()?['profilePictureUrl']};
    // } catch (e) {
    //   print("Error fetching user $userId: $e");
    // }
    // return null;
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network
    return {'name': 'User $userId'.substring(0, 10)}; // Placeholder name
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          _buildSliverAppBar(context, colorScheme, textTheme),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildCommunityInfoSection(context, textTheme, colorScheme),
                const SizedBox(height: 24),
                _buildStatsSection(context, textTheme, colorScheme),
                const SizedBox(height: 24),
                _buildMembersSection(context, textTheme, colorScheme),
                const SizedBox(height: 24),
                _buildPostsSection(context, textTheme, colorScheme),
                const SizedBox(height: 24),
                // You could add more sections here, e.g., Rules, Events
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor:
          colorScheme.surfaceContainer, // Or primary for a bolder look
      iconTheme: IconThemeData(
        color: colorScheme.onSurfaceVariant,
      ), // Back button color
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true, // Or false if you prefer left alignment on collapse
        titlePadding: const EdgeInsets.symmetric(
          horizontal: 48.0,
          vertical: 12.0,
        ), // Adjust as needed
        title: Text(
          community.name,
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface, // Color when collapsed
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        background:
            community.imageUrl != null && community.imageUrl!.isNotEmpty
                ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      community.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              _buildImagePlaceholder(
                                context,
                                colorScheme,
                                textTheme,
                              ),
                    ),
                    Container(
                      // Gradient overlay for better title readability
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.4),
                          ],
                          stops: const [0.5, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ],
                )
                : _buildImagePlaceholder(
                  context,
                  colorScheme,
                  textTheme,
                  showIcon: true,
                ),
        stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.share_outlined, color: colorScheme.onSurfaceVariant),
          tooltip: 'Share Community',
          onPressed: () {
            /* TODO: Implement share functionality */
          },
        ),
        IconButton(
          icon: Icon(
            Icons.more_vert_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
          tooltip: 'More Options',
          onPressed: () {
            /* TODO: Implement more options */
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildImagePlaceholder(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme, {
    bool showIcon = false,
  }) {
    return Container(
      width: double.infinity,
      height: 200,
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child:
            showIcon
                ? Icon(
                  Icons.groups_2_outlined,
                  size: 80,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                )
                : Text(
                  community.name[0].toUpperCase(),
                  style: textTheme.displayLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  Widget _buildCommunityInfoSection(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          community
              .name, // Display name again here, as SliverAppBar title might be short
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "About this community",
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          community.description,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        // Example: Creator Info (if available)
        // const SizedBox(height: 12),
        // Row(
        //   children: [
        //     Icon(Icons.shield_outlined, size: 18, color: colorScheme.onSurfaceVariant),
        //     const SizedBox(width: 8),
        //     Text(
        //       "Created by: ", // Add community.creatorName or similar
        //       style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        //     ),
        //     Text(
        //       "Admin User", // community.creatorName
        //       style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            icon: Icons.group_outlined,
            label: "Members",
            value: community.members.length.toString(),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          // Example: Add more stats if available
          // _buildStatItem(
          //   context,
          //   icon: Icons.article_outlined,
          //   label: "Posts",
          //   value: "125", // community.postCount.toString(),
          //   colorScheme: colorScheme,
          //   textTheme: textTheme,
          // ),
          // _buildStatItem(
          //   context,
          //   icon: Icons.calendar_today_outlined,
          //   label: "Created",
          //   value: "Jan 2024", // Format community.creationDate,
          //   colorScheme: colorScheme,
          //   textTheme: textTheme,
          // ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: colorScheme.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildMembersSection(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Members (${community.members.length})',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            if (community.members.length > 5) // Show "View All" if many members
              TextButton(
                onPressed: () {
                  /* TODO: Navigate to full members list screen */
                },
                child: Text(
                  'View All',
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (community.members.isNotEmpty)
          SizedBox(
            height: 80, // Adjust height for avatar previews
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  community.members.length > 10
                      ? 10
                      : community.members.length, // Show max 10 previews
              itemBuilder: (context, index) {
                final memberId = community.members[index];
                // FutureBuilder to fetch actual member data
                return FutureBuilder<Map<String, dynamic>?>(
                  future: _fetchUserDetails(
                    memberId,
                  ), // Replace with your actual data fetching
                  builder: (context, snapshot) {
                    String? memberName = snapshot.data?['name'] ?? 'Loading...';
                    String? avatarUrl = snapshot.data?['avatarUrl'];

                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: colorScheme.secondaryContainer,
                            backgroundImage:
                                avatarUrl != null
                                    ? NetworkImage(avatarUrl)
                                    : null,
                            child:
                                avatarUrl == null
                                    ? Text(
                                      memberName!.isNotEmpty
                                          ? memberName[0].toUpperCase()
                                          : '?',
                                      style: textTheme.titleMedium?.copyWith(
                                        color: colorScheme.onSecondaryContainer,
                                      ),
                                    )
                                    : null,
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 60, // Max width for name under avatar
                            child: Text(
                              memberName!,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'No members yet. Be the first to join!',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        // Fallback or detailed list (optional, if not using "View All" for everything)
        // if (community.members.isNotEmpty && community.members.length <= 5) // Show list for few members
        //   ListView.builder(
        //     shrinkWrap: true,
        //     physics: const NeverScrollableScrollPhysics(),
        //     itemCount: community.members.length,
        //     itemBuilder: (context, index) {
        //       // ... (your existing ListTile based member display, but styled better)
        //     },
        //   )
      ],
    );
  }

  Widget _buildPostsSection(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    // In a real app, you'd fetch and display posts here.
    bool hasPosts = false; // Replace with actual post check

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Posts',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            FloatingActionButton.small(
              onPressed: () {
                /* TODO: Navigate to create post screen */
              },
              tooltip: 'Create Post',
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
              elevation: 1.0,
              child: const Icon(Icons.add_comment_outlined),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (hasPosts)
          // TODO: Implement ListView.builder for posts
          const Text('Posts would appear here.')
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              // border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5))
            ),
            child: Column(
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 48,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'No posts in this community yet.',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to share something!',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
