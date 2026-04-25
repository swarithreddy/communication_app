import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _nickname = '';

  @override
  void initState() {
    super.initState();
    _loadNickname();
  }

  Future<void> _loadNickname() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nickname = prefs.getString('nickname') ?? 'Unknown';
    });
  }

  // Dummy device list for now — Sprint 2 will fill this with real BLE devices
  final List<Map<String, String>> _mockDevices = [
    {'name': 'Ravi\'s Phone', 'id': '00:11:22:33:44:55'},
    {'name': 'Priya\'s Phone', 'id': '66:77:88:99:AA:BB'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MeshComm'),
        actions: [
          // Show your own nickname in top right
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                _nickname,
                style: const TextStyle(color: Color(0xFF1D9E75), fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status banner
          Container(
            width: double.infinity,
            color: const Color(0xFF1D9E75).withOpacity(0.15),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: const Row(
              children: [
                Icon(Icons.bluetooth_searching, size: 18, color: Color(0xFF1D9E75)),
                SizedBox(width: 8),
                Text('Scanning for nearby devices...', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),

          // Device list
          Expanded(
            child: _mockDevices.isEmpty
                ? const Center(child: Text('No devices found nearby'))
                : ListView.builder(
                    itemCount: _mockDevices.length,
                    itemBuilder: (context, index) {
                      final device = _mockDevices[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.phone_android),
                        ),
                        title: Text(device['name']!),
                        subtitle: Text(device['id']!),
                        trailing: FilledButton.tonal(
                          onPressed: () {
                            // Navigate to chat screen with this device
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  deviceName: device['name']!,
                                  myNickname: _nickname,
                                ),
                              ),
                            );
                          },
                          child: const Text('Connect'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // Floating button to manually scan
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Sprint 2: real BLE scan goes here
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('BLE scanning coming in Sprint 2!')),
          );
        },
        icon: const Icon(Icons.search),
        label: const Text('Scan'),
      ),
    );
  }
}