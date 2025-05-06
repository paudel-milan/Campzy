import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  File? _file;
  final ImagePicker _picker = ImagePicker();
  String _selectedTag = 'general';
  bool _isPosting = false;
  String _currentUsername = 'Anonymous';
  String _currentUserProfilePic = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserDetails();
  }

  Future<void> _fetchCurrentUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _currentUsername = userDoc['username'] ?? 'Anonymous';
          _currentUserProfilePic = userDoc['profilePic'] ?? '';
        });
      }
    }
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _file = File(pickedFile.path);
      });
    }
  }

  // Pick file (any file type)
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _file = File(result.files.single.path!);
      });
    }
  }

  // Upload file to Firebase Storage
  Future<String> _uploadFile() async {
    if (_file == null) return '';
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      UploadTask uploadTask = FirebaseStorage.instance.ref('posts/$fileName').putFile(_file!);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      return '';
    }
  }

  // Show file source selection modal
  void _showFileSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(10),
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: Icon(IconlyBold.camera, color: Color(0xFF7851A9)),
                title: Text("Take a Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: Icon(IconlyBold.upload, color: Color(0xFF7851A9)),
                title: Text("Choose a File"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Post data to Firestore
  Future<void> _post() async {
    if (_isPosting) return;

    setState(() {
      _isPosting = true;
    });

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in.')),
      );
      setState(() {
        _isPosting = false;
      });
      return;
    }

    if (_descriptionController.text.trim().isEmpty || _titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a title and description.')),
      );
      setState(() {
        _isPosting = false;
      });
      return;
    }

    String imageUrl = await _uploadFile();
    String postId = FirebaseFirestore.instance.collection('posts').doc().id;

    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).set({
        'postId': postId,
        'uid': user.uid,
        'username': _currentUsername, // Use the fetched username
        'profilePicUrl': _currentUserProfilePic, // Use the fetched profile pic URL
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'imageUrl': imageUrl,
        'upvotes': 0,
        'downvotes': 0,
        'commentsCount': 0,
        'tag': _selectedTag,
        'postType': imageUrl.isEmpty ? 'text' : 'image',
        'createdAt': Timestamp.now(),
      });

      print('✅ Post created successfully with ID: $postId'); // Log success

      _descriptionController.clear();
      _titleController.clear();
      setState(() {
        _file = null;
        _selectedTag = 'general';
        _isPosting = false;
      });

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print('❌ Error posting: $e'); // Log the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post. Try again later.')),
      );
      setState(() {
        _isPosting = false;
      });
    }
  }

  // Build dropdown for selecting post tags
  Widget _buildTagDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedTag,
      onChanged: (val) => setState(() => _selectedTag = val!),
      items: ['general', 'tech', 'college', 'fun']
          .map((tag) => DropdownMenuItem(value: tag, child: Text(tag)))
          .toList(),
      decoration: InputDecoration(
        labelText: 'Select Tag',
        border: OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text("User not logged in"));
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: _currentUserProfilePic.isNotEmpty
                              ? NetworkImage(_currentUserProfilePic)
                              : null,
                          child: _currentUserProfilePic.isEmpty
                              ? Icon(Icons.person, size: 30)
                              : null,
                        ),
                        SizedBox(width: 10),
                        Text(
                          _currentUsername,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Post Title',
                        hintText: 'Enter a title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        filled: true,
                        fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildTagDropdown(),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: _showFileSourceSelection,
                      child: _file == null
                          ? Icon(IconlyBold.image, size: 40, color: Color(0xFF7851A9))
                          : Image.file(_file!, width: 150, height: 150, fit: BoxFit.cover),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF7851A9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _post,
                        child: Text('Post', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isPosting)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7851A9)),
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