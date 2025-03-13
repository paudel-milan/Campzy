import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Request Permission for Photos
  Future<void> _requestPermission() async {
    PermissionStatus status = await Permission.photos.request();
    if (status.isGranted) {
      // If permission is granted, pick the image
      _pickImage();
    } else if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied. Please allow access to photos.')),
      );
    }
  }

  // Pick Image from Gallery
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  // Upload Image to Firebase Storage
  Future<String> _uploadImage() async {
    if (_imageFile == null) return '';

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      UploadTask uploadTask = FirebaseStorage.instance
          .ref('posts/$fileName')
          .putFile(_imageFile!);

      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
        backgroundColor: Color(0xFF7851A9),
        elevation: 0,
      ),
      body: user == null
          ? Center(child: Text("You need to log in to create a post"))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(
                    user.photoURL ?? 'https://www.example.com/default_profile_pic.png',
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  user.displayName ?? user.email ?? 'Anonymous',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Title input field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Post Title',
                hintText: 'Enter a title for your post',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
            ),
            SizedBox(height: 20),

            // Description input field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'What\'s on your mind?',
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Image picker button
            GestureDetector(
              onTap: _requestPermission,  // Request permission before picking image
              child: _imageFile == null
                  ? Icon(
                Icons.add_photo_alternate,
                color: Color(0xFF7851A9),
                size: 40,
              )
                  : Image.file(
                _imageFile!,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),

            // Post Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7851A9),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  if (_descriptionController.text.trim().isEmpty ||
                      _titleController.text.trim().isEmpty) {
                    return;
                  }

                  // Upload image if available
                  String imageUrl = await _uploadImage();

                  // Add the post data to Firestore
                  await FirebaseFirestore.instance.collection('posts').add({
                    'authorId': user.displayName ?? user.email ?? 'Anonymous',
                    'createdAt': Timestamp.now(),
                    'description': _descriptionController.text.trim(),
                    'imageUrl': imageUrl,
                    'title': _titleController.text.trim(),
                  });

                  // Clear the input fields and go back to the home screen
                  _descriptionController.clear();
                  _titleController.clear();
                  setState(() {
                    _imageFile = null;
                  });
                  Navigator.pushReplacementNamed(context, '/home');  // Navigate to Home
                },
                child: Text(
                  'Post',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
