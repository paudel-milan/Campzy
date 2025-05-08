import 'package:flutter/material.dart';
import 'package:mad/features/communities/community_details_screen.dart';
import 'package:mad/features/communities/services/community_service.dart';
import 'package:mad/models/community_model.dart';
import 'package:provider/provider.dart';
import 'package:mad/providers/auth_provider.dart';

class CommunitiesScreen extends StatelessWidget {
  const CommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Safe provider lookup with error handling
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final communityService = Provider.of<CommunityService>(context, listen: false);

    // Get current user safely
    final currentUser = authProvider.user;
    final isLoggedIn = authProvider.isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities'),
        actions: [
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateCommunityDialog(context),
            ),
        ],
      ),
      body: StreamBuilder<List<Community>>(
        stream: communityService.getCommunities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final communities = snapshot.data ?? [];

          return ListView.builder(
            itemCount: communities.length,
            itemBuilder: (context, index) {
              final community = communities[index];
              final isMember = isLoggedIn &&
                  community.members.contains(currentUser?.uid);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: community.imageUrl != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(community.imageUrl!),
                        )
                      : const CircleAvatar(child: Icon(Icons.people)),
                  title: Text(community.name),
                  subtitle: Text(community.description),
                  trailing: isLoggedIn
                      ? IconButton(
                          icon: Icon(
                            isMember ? Icons.check_circle : Icons.add_circle,
                            color: isMember
                                ? Colors.green
                                : Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            if (isMember) {
                              communityService.leaveCommunity(
                                  community.id, currentUser!.uid);
                            } else {
                              communityService.joinCommunity(
                                  community.id, currentUser!.uid);
                            }
                          },
                        )
                      : null,
                  // 
                  onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CommunityDetailsScreen(community: community),
    ),
  );
},
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateCommunityDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateCommunityDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final communityService = Provider.of<CommunityService>(context, listen: false);

    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to create a community.')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    String name = '';
    String description = '';
    // You might want to add a field for imageUrl here as well

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Community'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Name is required' : null,
                  onChanged: (value) => name = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Description is required' : null,
                  onChanged: (value) => description = value,
                ),
                // You can add a TextFormField for imageUrl here if needed
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await communityService.createCommunity(
                      name: name,
                      description: description,
                      creatorId: authProvider.user!.uid,
                      // You can pass imageUrl here if you added a field for it
                    );
                    Navigator.pop(context);
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
}
