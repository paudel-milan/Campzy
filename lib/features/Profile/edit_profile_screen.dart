import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  EditProfileScreen({required this.userData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _bioController = TextEditingController();
  bool _isUpdating = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _bioController.text = widget.userData['bio'] ?? "";
    _imageUrl = widget.userData['profilePic']; // Load existing profile pic
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? pickedFile;

    if (kIsWeb) {
      // For web, open file picker
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      // Read image as bytes
      final bytes = await pickedFile.readAsBytes();
      final storageRef = FirebaseStorage.instance.ref().child('profilePics/${FirebaseAuth.instance.currentUser!.uid}.jpg');
      final uploadTask = storageRef.putData(bytes);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        _imageUrl = downloadUrl;
      });
    } else {
      // For mobile
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      File file = File(pickedFile.path);
      final storageRef = FirebaseStorage.instance.ref().child('profilePics/${FirebaseAuth.instance.currentUser!.uid}.jpg');
      final uploadTask = storageRef.putFile(file);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        _imageUrl = downloadUrl;
      });
    }

    // Update Firestore
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
      'profilePic': _imageUrl,
    });
  }

  Future<void> _updateBio() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'bio': _bioController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile updated successfully!")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating profile")));
    }

    setState(() {
      _isUpdating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile"), backgroundColor: Color(0xFF7851A9)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickAndUploadImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageUrl != null ? NetworkImage(_imageUrl!) : AssetImage("assets/default_avatar.png") as ImageProvider,
                  child: _imageUrl == null ? Icon(Icons.camera_alt, size: 40) : null,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("Bio", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Write something about yourself",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _isUpdating
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF7851A9)),
              onPressed: _updateBio,
              child: Text("Save Changes", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
