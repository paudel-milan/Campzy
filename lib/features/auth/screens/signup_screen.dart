import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;

  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  void _signup() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Provider.of<AuthService>(context, listen: false)
          .signUpWithEmailPassword(_emailController.text, _passwordController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup failed: $e")),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Campzy",
              style: GoogleFonts.lobster(
                fontSize: 50,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 40),
            _buildTextField(_emailController, "Name", Icons.person, false, theme),
            SizedBox(height: 10),
            _buildTextField(_emailController, "Email", Icons.email, false, theme),
            SizedBox(height: 10),
            _buildTextField(_passwordController, "Password", Icons.lock, true, theme),
            SizedBox(height: 10),
            _buildTextField(_confirmPasswordController, "Confirm Password", Icons.lock, true, theme),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _signup,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isLoading ? CircularProgressIndicator() : Text("Sign Up"),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account?", style: TextStyle(color: theme.colorScheme.onBackground)),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  ),
                  child: Text("Log In", style: TextStyle(color: theme.colorScheme.secondary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isPassword, ThemeData theme) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _isObscure : false,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: theme.hintColor),
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor ?? Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor, width: 1),
        ),
        prefixIcon: Icon(icon, color: theme.iconTheme.color),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
          color: theme.iconTheme.color,
          onPressed: _togglePasswordVisibility,
        )
            : null,
      ),
      keyboardType: isPassword ? TextInputType.visiblePassword : TextInputType.emailAddress,
      style: TextStyle(fontSize: 16, color: theme.textTheme.bodyLarge?.color),
    );
  }
}