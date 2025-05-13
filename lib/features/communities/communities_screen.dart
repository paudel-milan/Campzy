import 'package:flutter/material.dart';
import 'package:mad/features/communities/community_details_screen.dart';
import 'package:mad/features/communities/services/community_service.dart';
import 'package:mad/models/community_model.dart';
import 'package:provider/provider.dart';
import 'package:mad/providers/auth_provider.dart';

class CommunitiesScreen extends StatelessWidget {
  const CommunitiesScreen({super.key});

  Widget _buildJoinLeaveButton(
    BuildContext context,
    CommunityService communityService,
    Community community,
    String currentUserId,
    bool isMember,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isMember) {
      return OutlinedButton.icon(
        icon: const Icon(Icons.check_circle_outline, size: 20),
        label: const Text('Joined'),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary.withOpacity(0.7)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          communityService.leaveCommunity(community.id, currentUserId);
        },
      );
    } else {
      return ElevatedButton.icon(
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Join'),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          communityService.joinCommunity(community.id, currentUserId);
        },
      );
    }
  }

  void _showCreateCommunityDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final communityService = Provider.of<CommunityService>(
      context,
      listen: false,
    );
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (!authProvider.isLoggedIn || authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to be logged in to create a community.'),
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    String name = '';
    String description = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: colorScheme.surfaceContainerHigh,
          title: Text(
            'Create New Community',
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Community Name',
                    hintText: 'e.g., Flutter Devs Worldwide',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  style: TextStyle(color: colorScheme.onSurface),
                  validator:
                      (value) =>
                          value?.isEmpty ?? true ? 'Name is required' : null,
                  onChanged: (value) => name = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Share tips, projects, and connect!',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  style: TextStyle(color: colorScheme.onSurface),
                  maxLines: 3,
                  minLines: 1,
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? 'Description is required'
                              : null,
                  onChanged: (value) => description = value,
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await communityService.createCommunity(
                      name: name,
                      description: description,
                      creatorId: authProvider.user!.uid,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Community "$name" created!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error creating community: $e')),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final communityService = Provider.of<CommunityService>(
      context,
      listen: false,
    );
    final currentUser = authProvider.user;
    final isLoggedIn = authProvider.isLoggedIn;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: StreamBuilder<List<Community>>(
        stream: communityService.getCommunities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: colorScheme.error,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Something went wrong',
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final communities = snapshot.data ?? [];

          if (communities.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.forum_outlined,
                      size: 80,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No communities yet.',
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isLoggedIn
                          ? 'Why not start one and invite others to join?'
                          : 'Log in or sign up to discover and create communities.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isLoggedIn) ...[
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Create a Community'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          textStyle: textTheme.labelLarge,
                        ),
                        onPressed: () => _showCreateCommunityDialog(context),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 8.0,
            ),
            itemCount: communities.length,
            itemBuilder: (context, index) {
              final community = communities[index];
              final isMember =
                  isLoggedIn &&
                  currentUser != null &&
                  community.members.contains(currentUser.uid);

              return Card(
                elevation: 0.5, // Subtle elevation
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  // side: BorderSide(color: colorScheme.outline.withOpacity(0.5)) // Optional border
                ),
                color: colorScheme.surfaceContainerLow,
                clipBehavior:
                    Clip.antiAlias, // Ensures ripple respects border radius
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                CommunityDetailsScreen(community: community),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: colorScheme.primaryContainer,
                          backgroundImage:
                              community.imageUrl != null &&
                                      community.imageUrl!.isNotEmpty
                                  ? NetworkImage(community.imageUrl!)
                                  : null,
                          child:
                              (community.imageUrl == null ||
                                      community.imageUrl!.isEmpty)
                                  ? Icon(
                                    Icons.people_alt_outlined,
                                    size: 30,
                                    color: colorScheme.onPrimaryContainer,
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                community.name,
                                style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                community.description,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isLoggedIn && currentUser != null) ...[
                          const SizedBox(width: 12),
                          _buildJoinLeaveButton(
                            context,
                            communityService,
                            community,
                            currentUser.uid,
                            isMember,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:
          isLoggedIn
              ? FloatingActionButton(
                onPressed: () => _showCreateCommunityDialog(context),
                tooltip: 'Create Community',
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                elevation: 2.0,
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}
