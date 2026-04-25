import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  // Controller listens to the text field
  final _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveNickname() async {
    final nickname = _controller.text.trim();

    // Don't save if empty
    if (nickname.isEmpty) return;

    setState(() => _isLoading = true);

    // Save to device storage permanently
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname', nickname);

    // Navigate to home screen, remove setup from back stack
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon placeholder
              const Icon(Icons.wifi_tethering, size: 80, color: Color(0xFF1D9E75)),
              const SizedBox(height: 24),

              const Text(
                'MeshComm',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Communicate without internet',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 48),

              // Nickname input
              TextField(
                controller: _controller,
                maxLength: 20,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Your nickname',
                  hintText: 'e.g. Swarith',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                onSubmitted: (_) => _saveNickname(),
              ),
              const SizedBox(height: 16),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveNickname,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Get Started'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}