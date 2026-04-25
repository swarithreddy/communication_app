import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  // Stream of scan results — home screen will listen to this
  static Stream<List<ScanResult>> get scanResults =>
      FlutterBluePlus.scanResults;

  // Check if currently scanning
  static Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  // Start scanning for nearby BLE devices (10 second timeout)
  static Future<void> startScan() async {
    // Stop any existing scan first
    await FlutterBluePlus.stopScan();

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
    );
  }

  // Stop scanning manually
  static Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  // Connect to a device
  static Future<void> connect(BluetoothDevice device) async {
    await device.connect(autoConnect: false);
  }

  // Disconnect from a device
  static Future<void> disconnect(BluetoothDevice device) async {
    await device.disconnect();
  }
}