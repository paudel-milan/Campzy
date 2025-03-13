import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mad/core/splash_screen.dart';
import 'package:mad/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'features/auth/services/auth_service.dart';
import 'firebase_options.dart';
import 'features/home/screens/home_screen.dart';
import 'providers/post_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => PostProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campzy',
      themeMode: themeProvider.themeMode, // Uses ThemeProvider's theme mode
      theme: ThemeData.light(), // Default Light Theme
      darkTheme: ThemeData.dark(), // Dark Theme
      home:  SplashScreen(),
    );
  }
}
