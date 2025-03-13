import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/models/post_model.dart';
import 'package:intl/intl.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white, // Dark background like Reddit
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author ID (modify this to show username if available)
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[800],
                child: Icon(Icons.person, color: Colors.white),
              ),
              SizedBox(width: 10),
              Text(
                post.authorId, // Use the author's name here
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
              Spacer(),
              Icon(Icons.more_vert, color: Colors.black),
            ],
          ),

          SizedBox(height: 10),

          // Post Title
          Text(
            post.title,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),

          SizedBox(height: 5),

          // Post Description
          Text(
            post.description,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),

          SizedBox(height: 10),

          // Image (if available)
          if (post.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(post.imageUrl, fit: BoxFit.cover),
            ),

          SizedBox(height: 10),

          // Post Date
          Text(
            "Posted on ${DateFormat.yMMMd().format((post.createdAt as Timestamp).toDate())}",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),

          SizedBox(height: 10),

          // Interaction Buttons (Like, Comment, Share)
          Row(
            children: [
              Icon(Icons.arrow_upward, color: Colors.black),
              SizedBox(width: 5),
              Text("467", style: TextStyle(color: Colors.black)),

              SizedBox(width: 20),

              Icon(Icons.comment, color: Colors.black),
              SizedBox(width: 5),
              Text("1,327", style: TextStyle(color: Colors.black)),

              SizedBox(width: 20),

              Icon(Icons.share, color: Colors.black),
              SizedBox(width: 5),
              Text("204", style: TextStyle(color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }
}
