import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:mad/core/splash_screen.dart';
import 'package:mad/providers/auth_provider.dart';
import 'package:mad/providers/chat_provider.dart';
import 'package:mad/providers/theme_provider.dart';
import 'package:mad/providers/auth_provider.dart'; // Added AuthProvider
import 'package:mad/providers/post_provider.dart';
import 'package:mad/providers/community_provider.dart';
import 'package:mad/features/auth/services/auth_service.dart';
import 'package:mad/features/communities/services/community_service.dart';
import 'firebase_options.dart';


void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/.env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => AuthService()),
        // ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => PostProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(
      MultiProvider(
        providers: [
          // Services
          Provider(create: (context) => AuthService()),
          Provider(create: (context) => CommunityService()),
          
          // Providers with state management
          ChangeNotifierProvider(create: (context) => AuthProvider()),
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => PostProvider()),
          ChangeNotifierProvider(create: (context) => CommunityProvider(
            Provider.of<CommunityService>(context, listen: false),
          )),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    // Handle initialization errors
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Initialization failed: $e'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campzy',
      themeMode: themeProvider.themeMode,
      theme: ThemeData.light().copyWith(
        // Add your light theme customizations here
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.light().copyWith(secondary: Colors.blueAccent),
      ),
      darkTheme: ThemeData.dark().copyWith(
        // Add your dark theme customizations here
        primaryColor: Colors.blueGrey,
        colorScheme: ColorScheme.dark().copyWith(secondary: Colors.blueGrey[300]),
      ),
      home: SplashScreen(),
      // Add your routes here if needed
      // routes: {
      //   '/home': (context) => HomeScreen(),
      // },
    );
  }
}
