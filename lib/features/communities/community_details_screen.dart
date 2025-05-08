// lib/features/communities/community_details_screen.dart
import 'package:flutter/material.dart';
import 'package:mad/models/community_model.dart';

class CommunityDetailsScreen extends StatelessWidget {
  final Community community;

  const CommunityDetailsScreen({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(community.name), // Corrected: Using community.name for the title
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (community.imageUrl != null)
              Image.network(
                community.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.image, size: 60)),
              ),
            const SizedBox(height: 16),
            Text(
              community.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              community.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Members:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (community.members.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: community.members.length,
                itemBuilder: (context, index) {
                  final memberId = community.members[index];
                  // You might want to fetch user details based on memberId
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text('User ID: $memberId'), // Replace with actual username if fetched
                  );
                },
              )
            else
              const Text('No members yet.'),
            const SizedBox(height: 16),
            const Text(
              'Posts:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('No posts in this community yet.'), // You'll need to implement post fetching here
            // Future: Display list of posts related to this community
          ],
        ),
      ),
    );
  }
}