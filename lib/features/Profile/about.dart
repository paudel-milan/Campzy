import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xFF7851A9),
        primarySwatch: Colors.purple,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primaryColor: const Color(0xFF7851A9),
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const AboutPage(),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF7851A9);
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final dividerColor = isDarkMode ? Colors.white24 : Colors.black12;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: backgroundColor,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildListTile(context, 'Terms of Service', Icons.description_outlined, primaryColor, textColor),
            _buildListTile(context, 'Privacy Policy', Icons.privacy_tip_outlined, primaryColor, textColor),
            _buildListTile(context, 'Content Policy', Icons.policy_outlined, primaryColor, textColor),
            _buildListTile(context, 'Help Center', Icons.help_outline, primaryColor, textColor),
            _buildListTile(context, 'Report an Issue', Icons.bug_report_outlined, primaryColor, textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, String title, IconData icon, Color primaryColor, Color textColor) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: Icon(Icons.chevron_right, color: textColor.withOpacity(0.5)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InfoPage(title: title)),
        );
      },
    );
  }
}

class InfoPage extends StatelessWidget {
  final String title;
  const InfoPage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF7851A9),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: backgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: Text(
          _getContent(title),
          style: TextStyle(fontSize: 16, color: textColor),
        ),
      ),
    );
  }

  String _getContent(String title) {
    switch (title) {
      case 'Terms of Service':
        return '''
1.  Acceptance of Terms  
   - By using the platform, you agree to abide by these terms.
   - Violation of terms may result in content removal, account suspension, or legal action.

2.   User Conduct  
   - No hate speech, harassment, or threats.
   - No spamming, misleading information, or illegal content.
   - Respect the intellectual property rights of others.

3.   Content Ownership & Rights  
   - Users retain ownership of their content.
   - By posting, users grant the platform a license to use, display, and distribute content.

4.   Moderation & Enforcement  
   - Moderators and administrators can remove content that violates rules.
   - Users can report violations for review.
   - The platform reserves the right to suspend or ban accounts.

5.   Privacy & Data Usage  
   - User data is collected for platform functionality and improvement.
   - Personal data is not shared without consent, except as required by law.

6.   Advertising & Monetization  
   - The platform may display ads based on user activity.
   - Users may monetize content through approved programs.

7. Liability & Disclaimers
   - The platform is not responsible for user-generated content.
   - The platform does not guarantee uninterrupted service.

8. Changes to Terms
   - The platform may update terms at any time.
   - Users will be notified of major changes.
''';
      case 'Privacy Policy':
        return 'We collect user data to enhance the experience. Your personal information is protected and not shared with third parties without consent.';
      case 'Content Policy':
        return 'Our content policy prohibits hate speech, harassment, and inappropriate content. Violations may result in content removal or account suspension.';
      case 'Help Center':
        return 'Need help? Visit our help center for FAQs and support resources, or contact us at support@campzy.com.';
      case 'Report an Issue':
        return 'If you encounter a problem, report it through our in-app support or email us at report@campzy.com.';
      default:
        return 'Information not available.';
    }
  }
}




// Usage example:
// Add this to your main.dart or routes
// 
// MaterialApp(
//   theme: ThemeData(
//     primaryColor: const Color(0xFF7851A9),
//     primarySwatch: Colors.purple,
//     brightness: Brightness.light,
//   ),
//   darkTheme: ThemeData(
//     primaryColor: const Color(0xFF7851A9),
//     primarySwatch: Colors.purple,
//     brightness: Brightness.dark,
//   ),
//   themeMode: ThemeMode.system, // or ThemeMode.dark or ThemeMode.light
//   home: const AboutPage(),
// )