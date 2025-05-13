import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_iconly/flutter_iconly.dart'; // You are using this, good.
import 'package:firebase_auth/firebase_auth.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  File? _file;
  String? _fileName; // To display the name of the selected file
  final ImagePicker _picker = ImagePicker();
  String _selectedTag = 'general'; // Default tag
  bool _isPosting = false;
  String _currentUsername = 'Loading...';
  String _currentUserProfilePic = '';

  final Color themeColor = const Color(0xFF7851A9);

  final List<String> _availableTags = ['general', 'tech', 'college', 'fun', 'question', 'discussion', 'news'];


  @override
  void initState() {
    super.initState();
    _fetchCurrentUserDetails();
  }

  Future<void> _fetchCurrentUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && mounted) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (mounted && userDoc.exists) {
          setState(() {
            _currentUsername = userDoc.data()?['username'] ?? 'Anonymous';
            _currentUserProfilePic = userDoc.data()?['profilePic'] ?? '';
          });
        } else if (mounted) {
           setState(() => _currentUsername = 'User');
        }
      } catch (e) {
        if (mounted) {
          print("Error fetching user details: $e");
          setState(() => _currentUsername = 'User');
        }
      }
    } else if (mounted) {
       setState(() => _currentUsername = 'Guest');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
      if (pickedFile != null && mounted) {
        setState(() {
          _file = File(pickedFile.path);
          _fileName = pickedFile.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, // Allow specific types if needed
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'mov', 'pdf', 'doc', 'docx'], // Example
      );
      if (result != null && result.files.single.path != null && mounted) {
        setState(() {
          _file = File(result.files.single.path!);
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  Future<String> _uploadFile() async {
    if (_file == null) return '';
    setState(() => _isPosting = true); // Show loader specifically for upload
    try {
      String fileExtension = _fileName?.split('.').last ?? 'file';
      String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      UploadTask uploadTask = FirebaseStorage.instance.ref('posts_media/$uniqueFileName').putFile(_file!);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload file: ${e.toString()}')),
        );
      }
      return '';
    } finally {
      // No need to set _isPosting = false here, _post method handles overall posting state
    }
  }

  void _showFileSourceSelection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add Media",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(IconlyBold.camera, color: themeColor),
                title: Text("Take a Photo", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(IconlyBold.image, color: themeColor),
                title: Text("Choose from Gallery", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(IconlyBold.folder, color: themeColor),
                title: Text("Choose a File", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54)),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _post() async {
    if (_isPosting) return; // Prevent multiple submissions

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title for your post.')),
      );
      return;
    }
    if (description.isEmpty && _file == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description or add media.')),
      );
      return;
    }


    setState(() => _isPosting = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in. Please log in to post.')),
        );
      }
      setState(() => _isPosting = false);
      return;
    }

    String mediaUrl = "";
    String postType = "text";

    if (_file != null) {
      mediaUrl = await _uploadFile();
      if (mediaUrl.isEmpty && mounted) { // Upload failed
        setState(() => _isPosting = false);
        return; // Stop posting if file upload failed
      }
      // Determine postType based on file extension
      String extension = _fileName?.split('.').last.toLowerCase() ?? '';
      if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
        postType = 'image';
      } else if (['mp4', 'mov', 'avi'].contains(extension)) {
        postType = 'video';
      } else {
        postType = 'file'; // General file type
      }
    }


    String postId = FirebaseFirestore.instance.collection('posts').doc().id;

    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).set({
        'postId': postId,
        'uid': user.uid,
        'username': _currentUsername,
        'profilePicUrl': _currentUserProfilePic,
        'title': title,
        'description': description,
        'imageUrl': postType == 'image' || postType == 'video' ? mediaUrl : '', // Only store URL if it's image/video
        'fileUrl': postType == 'file' ? mediaUrl : '', // Store URL if it's a general file
        'fileName': postType == 'file' ? _fileName : '', // Store file name if it's a general file
        'upvotes': 0,
        'downvotes': 0,
        'commentsCount': 0,
        'tag': _selectedTag,
        'postType': postType,
        'createdAt': Timestamp.now(),
      });

      if (mounted) {
        _descriptionController.clear();
        _titleController.clear();
        setState(() {
          _file = null;
          _fileName = null;
          _selectedTag = 'general';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
        // Navigate back or to home screen
        if (Navigator.canPop(context)) {
          Navigator.pop(context, true); // Pass true to indicate success
        }
      }
    } catch (e) {
      print('❌ Error posting: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post. Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  Widget _buildTagDropdown(bool isDarkMode) {
    return DropdownButtonFormField<String>(
      value: _selectedTag,
      onChanged: (val) {
        if (val != null) setState(() => _selectedTag = val);
      },
      decoration: InputDecoration(
        labelText: 'Select Tag',
        labelStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
      iconEnabledColor: themeColor,
      items: _availableTags.map((tag) {
        return DropdownMenuItem(
          value: tag,
          child: Text(
            tag[0].toUpperCase() + tag.substring(1), // Capitalize first letter
            style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    int maxLines = 1,
    bool isDarkMode = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
        hintStyle: TextStyle(color: isDarkMode ? Colors.grey[600] : Colors.grey[500]),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: themeColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      keyboardType: maxLines > 1 ? TextInputType.multiline : TextInputType.text,
    );
  }


  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBgColor = isDarkMode ? Colors.black : Colors.grey[50]!;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDarkMode ? Colors.white70 : Colors.black54),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          "Create New Post",
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton(
              onPressed: _isPosting ? null : _post, // Disable button when posting
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              child: _isPosting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text("Post"),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: themeColor.withOpacity(0.1),
                        backgroundImage: _currentUserProfilePic.isNotEmpty
                            ? CachedNetworkImageProvider(_currentUserProfilePic)
                            : null,
                        child: _currentUserProfilePic.isEmpty
                            ? Icon(Icons.person, size: 28, color: themeColor.withOpacity(0.8))
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _currentUsername,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _titleController,
                    labelText: 'Title',
                    hintText: 'Enter a catchy title for your post',
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    labelText: 'Description (Optional)',
                    hintText: "What's on your mind? Share more details...",
                    maxLines: 5,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  _buildTagDropdown(isDarkMode),
                  const SizedBox(height: 24),
                  Text(
                    "Add Media (Optional)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white70 : Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _showFileSourceSelection,
                    child: Container(
                      height: _file == null ? 120 : 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: _file == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(IconlyLight.upload, size: 40, color: themeColor),
                                const SizedBox(height: 8),
                                Text(
                                  "Tap to add image, video, or file",
                                  style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                                ),
                              ],
                            )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _file!,
                                      fit: BoxFit.contain, // Use contain to see whole image
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _fileName ?? "Selected File",
                                        style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close, color: Colors.redAccent, size: 20),
                                      onPressed: (){
                                        setState(() {
                                          _file = null;
                                          _fileName = null;
                                        });
                                      },
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                    ),
                  ),
                  const SizedBox(height: 80), // Space for the Post button in AppBar
                ],
              ),
            ),
            // Global loading overlay, only shown when _isPosting is true AND actively doing network op
            if (_isPosting)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
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