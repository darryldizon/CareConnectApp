import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/loading_screen.dart'; // 👈 Add this import

void main() {
  runApp(const CareConnectApp());
}

class CareConnectApp extends StatelessWidget {
  const CareConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareConnect',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,

      // 🌀 Start with loading screen instead of LoginScreen
      home: LoadingScreen(nextScreen: const LoginScreen()),
    );
  }
}
