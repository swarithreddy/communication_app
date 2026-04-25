import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/setup.dart';
import 'screens/home.dart';

void main() async {
  // This line makes sure Flutter is ready before we do anything
  WidgetsFlutterBinding.ensureInitialized();

  // Check if user has already set a nickname
  final prefs = await SharedPreferences.getInstance();
  final nickname = prefs.getString('nickname');

  runApp(MeshCommApp(hasNickname: nickname != null));
}

class MeshCommApp extends StatelessWidget {
  final bool hasNickname;
  const MeshCommApp({super.key, required this.hasNickname});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeshComm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D9E75), // our teal brand color
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // If nickname exists go to home, else go to setup
      home: hasNickname ? const HomeScreen() : const SetupScreen(),
    );
  }
}