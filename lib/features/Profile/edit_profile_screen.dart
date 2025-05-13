import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// universal_html is not needed if you are using putData with Uint8List for web
// import 'package:universal_html/html.dart' as html;

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _bioController = TextEditingController();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // For potential future validation
  bool _isUpdating = false;
  String? _imageUrl;
  Uint8List? _webImage; // For web image preview and upload

  @override
  void initState() {
    super.initState();
    _bioController.text = widget.userData['bio'] ?? "";
    _imageUrl = widget.userData['profilePic'];
  }

  Future<void> _pickAndUploadImage() async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);

    final ImagePicker picker = ImagePicker();
    XFile? pickedFile;

    try {
      pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (pickedFile == null) {
        setState(() => _isUpdating = false);
        return;
      }

      String fileName =
          'profilePics/${FirebaseAuth.instance.currentUser!.uid}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(fileName);
      String downloadUrl;

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        _webImage = bytes; // For immediate UI update on web
        final uploadTask = storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final snapshot = await uploadTask;
        downloadUrl = await snapshot.ref.getDownloadURL();
      } else {
        File file = File(pickedFile.path);
        final uploadTask = storageRef.putFile(file);
        final snapshot = await uploadTask;
        downloadUrl = await snapshot.ref.getDownloadURL();
      }

      setState(() {
        _imageUrl = downloadUrl;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'profilePic': _imageUrl});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Profile picture updated!"),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error uploading image: ${e.toString()}"),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      print("Error picking/uploading image: $e");
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _updateProfileData() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Add validation if needed
      if (_isUpdating) return;
      setState(() => _isUpdating = true);

      try {
        String uid = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'bio': _bioController.text.trim(),
          // 'profilePic': _imageUrl, // Image is updated separately now
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Profile updated successfully!"),
              backgroundColor:
                  Theme.of(
                    context,
                  ).colorScheme.primaryContainer, // Or inverseSurface
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true); // Pass true to indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error updating profile: ${e.toString()}"),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUpdating = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    ImageProvider<Object>? currentImageProvider;
    if (_webImage != null && kIsWeb) {
      currentImageProvider = MemoryImage(_webImage!);
    } else if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      currentImageProvider = NetworkImage(_imageUrl!);
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
        ),
        backgroundColor: colorScheme.surfaceContainer,
        elevation: 0, // M3 style
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Make button full width
            children: [
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: colorScheme.secondaryContainer,
                      backgroundImage: currentImageProvider,
                      child:
                          currentImageProvider == null
                              ? Icon(
                                Icons.person_outline,
                                size: 70,
                                color: colorScheme.onSecondaryContainer,
                              )
                              : null,
                    ),
                    Material(
                      // Using Material for custom shape and elevation on FAB
                      elevation: 2.0,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      color: colorScheme.tertiaryContainer,
                      child: InkWell(
                        onTap: _pickAndUploadImage,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.edit,
                            size: 24,
                            color: colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildInfoRow(
                context,
                icon: Icons.badge_outlined,
                label: "Username",
                value: widget.userData['username'] ?? "Not set",
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                icon: Icons.email_outlined,
                label: "Email",
                value: widget.userData['email'] ?? "Not set",
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _bioController,
                maxLines: 4,
                minLines: 2,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: "About Me (Bio)",
                  labelStyle: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  hintText: "Tell us a bit about yourself...",
                  hintStyle: textTheme.bodyLarge?.copyWith(
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
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withOpacity(0.7),
                    ),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                // validator: (value) { // Example validator
                //   if (value != null && value.length > 200) {
                //     return 'Bio cannot exceed 200 characters';
                //   }
                //   return null;
                // },
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: _isUpdating ? null : _updateProfileData,
                icon:
                    _isUpdating
                        ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: CircularProgressIndicator(
                            color: colorScheme.onPrimary,
                            strokeWidth: 3,
                          ),
                        )
                        : const Icon(Icons.save_alt_outlined),
                label: Text(_isUpdating ? "Saving..." : "Save Changes"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: colorScheme.outline.withOpacity(0.3))
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 22),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
