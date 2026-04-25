import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ble_service.dart';
import 'chat.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _nickname = '';
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _loadNickname();
    _listenToScanResults();
  }

  Future<void> _loadNickname() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nickname = prefs.getString('nickname') ?? 'Unknown';
    });
  }

  void _listenToScanResults() {
    // Listen to live scan results as devices are discovered
    BleService.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          // Only show devices that have a name
          _scanResults = results
              .where((r) => r.device.platformName.isNotEmpty)
              .toList();
        });
      }
    });

    // Listen to scanning state
    BleService.isScanning.listen((scanning) {
      if (mounted) {
        setState(() => _isScanning = scanning);
      }
    });
  }

  Future<void> _startScan() async {
    // Check if Bluetooth is on
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please turn on Bluetooth to scan'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _scanResults = []); // Clear old results
    await BleService.startScan();
  }

  @override
  void dispose() {
    BleService.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MeshComm'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                _nickname,
                style: const TextStyle(
                  color: Color(0xFF1D9E75),
                  fontWeight: FontWeight.bold,
                ),
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
            color: _isScanning
                ? const Color(0xFF1D9E75).withOpacity(0.15)
                : Colors.grey.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              children: [
                Icon(
                  _isScanning ? Icons.bluetooth_searching : Icons.bluetooth,
                  size: 18,
                  color: _isScanning ? const Color(0xFF1D9E75) : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  _isScanning
                      ? 'Scanning for nearby devices...'
                      : 'Tap Scan to find nearby devices',
                  style: const TextStyle(fontSize: 13),
                ),
                if (_isScanning) ...[
                  const Spacer(),
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ),

          // Device list
          Expanded(
            child: _scanResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bluetooth_disabled,
                            size: 64, color: Colors.grey.shade600),
                        const SizedBox(height: 16),
                        Text(
                          _isScanning
                              ? 'Looking for devices...'
                              : 'No devices found\nTap Scan to search',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _scanResults.length,
                    itemBuilder: (context, index) {
                      final result = _scanResults[index];
                      final device = result.device;
                      final rssi = result.rssi;

                      // Signal strength icon based on RSSI value
                      IconData signalIcon;
                      if (rssi > -60) {
                        signalIcon = Icons.signal_cellular_alt;
                      } else if (rssi > -80) {
                        signalIcon = Icons.signal_cellular_alt_2_bar;
                      } else {
                        signalIcon = Icons.signal_cellular_alt_1_bar;
                      }

                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF1D9E75),
                          child: Icon(Icons.phone_android, color: Colors.white),
                        ),
                        title: Text(device.platformName),
                        subtitle: Text(
                          '${device.remoteId} · ${rssi} dBm',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(signalIcon,
                                size: 16, color: const Color(0xFF1D9E75)),
                            const SizedBox(width: 8),
                            FilledButton.tonal(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      deviceName: device.platformName,
                                      myNickname: _nickname,
                                      device: device,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Connect'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isScanning ? null : _startScan,
        icon: _isScanning
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.search),
        label: Text(_isScanning ? 'Scanning...' : 'Scan'),
      ),
    );
  }
}