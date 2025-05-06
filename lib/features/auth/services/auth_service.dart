import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../models/user_model.dart'; // adjust path if needed

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if user is logged in
  User? getCurrentUser() => _auth.currentUser;

  bool isUserLoggedIn() => _auth.currentUser != null;

  // Sign up with email & password
  Future<UserCredential?> signUpWithEmailPassword(String email, String password, String username) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create AppUser model
      AppUser newUser = AppUser(
        uid: userCredential.user!.uid,
        username: username,
        email: email,
        bio: '',
        profilePic: '',
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());

      return userCredential;
    } catch (e) {
      print("Error signing up: $e");
      return null;
    }
  }

  // Sign in with email & password
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Build AppUser
        AppUser googleUserModel = AppUser(
          uid: user.uid,
          username: user.displayName ?? 'Unknown',
          email: user.email ?? '',
          bio: '',
          profilePic: user.photoURL ?? '',
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(
          googleUserModel.toMap(),
          SetOptions(merge: true),
        );
      }

      return userCredential;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}
