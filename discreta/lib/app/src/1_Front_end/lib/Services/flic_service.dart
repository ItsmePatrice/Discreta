import 'package:discreta/app/src/1_Front_end/lib/Services/log_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flic_button/flic_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class FlicService extends ChangeNotifier implements Flic2Listener {
  FlicService._privateConstructor();
  static final FlicService _instance = FlicService._privateConstructor();
  static FlicService get instance => _instance;

  late FlicButtonPlugin plugin;

  bool _isInitialized = false;

  bool isConnected = false;
  bool isScanning = false;
  String? lastError;

  final List<Flic2Button> discoveredButtons = [];
  final List<Flic2Button> pairedButtons = [];

  Future<void> init() async {
    final granted = await requestBluetoothPermissions();
    if (!granted) return;

    plugin = FlicButtonPlugin(flic2listener: this);

    await plugin.invokation;
    final buttons = await plugin.getFlic2Buttons();

    for (final button in buttons) {
      plugin.listenToFlic2Button(button.uuid);
    }

    _isInitialized = true;
    LogService.instance.logInfo(
      'FlicService initialized, paired buttons: ${pairedButtons.length}',
    );
  }

  Future<bool> requestBluetoothPermissions() async {
    if (Platform.isAndroid) {
      final results = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();
      return results.values.every((s) => s.isGranted);
    } else {
      // iOS
      return await Permission.bluetooth.request().isGranted;
    }
  }

  Future<void> startScan() async {
    if (!_isInitialized) return;
    lastError = null;
    discoveredButtons.clear();
    isScanning = true;
    plugin.scanForFlic2();
    notifyListeners();
    LogService.instance.logInfo(
      'FlicService started scanning for Flic buttons.',
    );
  }

  void stopScan() {
    if (!_isInitialized) return;
    plugin.cancelScanForFlic2();
    LogService.instance.logInfo(
      'FlicService stopped scanning for Flic buttons.',
    );
  }

  void connect(Flic2Button button) {
    plugin.connectButton(button.uuid);
  }

  void listen(Flic2Button button) {
    plugin.listenToFlic2Button(button.uuid);
  }

  void disconnect() {
    if (!_isInitialized) return;
    for (final button in pairedButtons) {
      plugin.disconnectButton(button.uuid);
      plugin.forgetButton(button.uuid);
    }
    pairedButtons.clear();
    discoveredButtons.clear();
    isConnected = false;
    notifyListeners();
  }

  @override
  void onButtonFound(Flic2Button button) {
    if (!discoveredButtons.any((b) => b.uuid == button.uuid)) {
      discoveredButtons.add(button);
    }
    notifyListeners();
  }

  /// Fired on startup for buttons that are already bonded to this phone.
  @override
  void onPairedButtonDiscovered(Flic2Button button) {
    if (!pairedButtons.any((b) => b.uuid == button.uuid)) {
      pairedButtons.add(button);
    }
    notifyListeners();
  }

  /// Fired (with a Bluetooth address string) when the SDK rediscovers a
  /// previously paired button. Use getFlic2Buttons() to get the full object.
  @override
  void onButtonDiscovered(String buttonAddress) {
    LogService.instance.logInfo('Button discovered at address: $buttonAddress');
    plugin.getFlic2ButtonByAddress(buttonAddress).then((button) {
      if (button != null) {
        if (!pairedButtons.any((p) => p.uuid == button.uuid)) {
          pairedButtons.add(button);
        }
        plugin.listenToFlic2Button(button.uuid);
        notifyListeners();
      }
    });
  }

  /// SDK confirms the button is connected and ready.
  @override
  void onButtonConnected() {
    isConnected = true;
    isScanning = false;
    notifyListeners();
  }

  @override
  void onButtonClicked(Flic2ButtonClick click) {
    // Handled by the rest of the app (e.g. trigger alert).
    // Add a callback/stream here if HomePage needs to react to clicks.
  }

  @override
  void onButtonUpOrDown(Flic2ButtonUpOrDown button) {}

  @override
  void onScanStarted() {
    isScanning = true;
    notifyListeners();
    LogService.instance.logInfo('FlicService scan started.');
  }

  @override
  void onScanCompleted() {
    isScanning = false;
    notifyListeners();
  }

  @override
  void onFlic2Error(String error) {
    lastError = error;
    isScanning = false;
    notifyListeners();
  }
}
