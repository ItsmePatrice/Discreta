import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:discreta/app/src/1_Front_end/Assets/colors.dart';
import 'package:discreta/app/src/1_Front_end/Assets/enum/text_size.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/discreta_button.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/discreta_text.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/loading_overlay.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/auth_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/log_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/message_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/notification_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/user_service.dart';
import 'package:discreta/l10n/app_localizations.dart';
import 'package:discreta/main.dart';
import 'package:flic_button/flic_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:permission_handler/permission_handler.dart' as Geolocator;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// Implement Flic2Listener directly on the state, exactly as the working example does.
class _HomePageState extends State<HomePage>
    with RouteAware, TickerProviderStateMixin
    implements Flic2Listener {
  // ---------------------------------------------------------------------------
  // App state
  // ---------------------------------------------------------------------------
  String? _firstName;
  bool _isLoading = false;

  bool _isProtectionActive = false;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  Timer? _countdownTimer;
  int _selectedMinutes = 15;

  bool _hasActiveTrackingSession = false;

  // ---------------------------------------------------------------------------
  // Flic2 state  (mirrors the working example pattern)
  // ---------------------------------------------------------------------------

  /// The plugin manager — null until initialized.
  FlicButtonPlugin? _flicButtonManager;

  /// All buttons discovered / retrieved, keyed by uuid.
  final Map<String, Flic2Button> _buttonsFound = {};

  /// The most recently connected button (used for disconnect).
  Flic2Button? _connectedButton;

  bool _isFlicScanning = false;
  bool _isFlicConnected = false;
  bool _showFlicPanel = false;

  /// Cooldown to prevent repeated alerts from rapid button presses.
  static const _alertCooldown = Duration(seconds: 30);
  DateTime? _lastAlertTime;

  // ---------------------------------------------------------------------------
  // Animations
  // ---------------------------------------------------------------------------
  late AnimationController _pulseController;
  late AnimationController _scanController;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFlic2();
      _initializePage();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    _countdownTimer?.cancel();
    // Dispose the plugin cleanly.
    _flicButtonManager?.disposeFlic2();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Flic2 initialization  (same pattern as the working example)
  // ---------------------------------------------------------------------------

  void _initFlic2() {
    setState(() {
      _flicButtonManager = FlicButtonPlugin(flic2listener: this);
    });
    _restorePairedButtons();
  }

  Future<void> _restorePairedButtons() async {
    if (_flicButtonManager == null) return;

    await _flicButtonManager!.invokation;

    final buttons = await _flicButtonManager!.getFlic2Buttons();
    if (buttons.isEmpty) return;

    // Register and listen to all buttons first
    for (final button in buttons) {
      setState(() => _buttonsFound[button.uuid] = button);
      _flicButtonManager!.listenToFlic2Button(button.uuid);
    }

    // Then connect only those not already connected
    for (final button in buttons) {
      if (button.connectionState !=
          Flic2ButtonConnectionState.connected_ready) {
        _flicButtonManager!.connectButton(button.uuid);
      }
    }

    // onButtonConnected() handles the UI update — no polling needed
  }

  // ---------------------------------------------------------------------------
  // Flic2 scan helpers
  // ---------------------------------------------------------------------------

  Future<void> _startScan() async {
    if (_flicButtonManager == null) return;
    if (_isFlicScanning) return;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      bool granted;
      if (androidInfo.version.sdkInt > 30) {
        granted =
            await Permission.bluetoothScan.request().isGranted &&
            await Permission.bluetoothConnect.request().isGranted;
      } else {
        granted =
            await Permission.bluetooth.request().isGranted &&
            await Permission.location.request().isGranted;
      }
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bluetooth permission required to scan.'),
            ),
          );
        }
        return;
      }
    }
    // On iOS, Core Bluetooth handles the permission prompt automatically

    _flicButtonManager!.scanForFlic2();
    _scanController.repeat();
    setState(() {
      _isFlicScanning = true;
      _showFlicPanel = true;
    });
  }

  void _stopScan() {
    _flicButtonManager?.cancelScanForFlic2();
    _scanController
      ..stop()
      ..reset();
    setState(() => _isFlicScanning = false);
  }

  void _toggleFlicPanel() {
    setState(() => _showFlicPanel = !_showFlicPanel);
  }

  /// Add a button to the map and immediately start listening to it —
  /// exactly as _addButtonAndListen does in the working example.
  void _addButtonAndListen(Flic2Button button) {
    setState(() {
      _buttonsFound[button.uuid] = button;
      _flicButtonManager?.listenToFlic2Button(button.uuid);
    });
  }

  /// Connect or disconnect a button (mirrors _connectDisconnectButton).
  Future<void> _connectButton(Flic2Button button) async {
    if (button.connectionState == Flic2ButtonConnectionState.disconnected) {
      if (!await Permission.bluetoothConnect.request().isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bluetooth connect permission required.'),
            ),
          );
        }
        return;
      }
      _flicButtonManager?.connectButton(button.uuid);
    } else {
      _flicButtonManager?.disconnectButton(button.uuid);
    }
    // _isFlicConnected will update via onButtonConnected / onButtonUpOrDown
    // callbacks — no need to set it here.
  }

  // ---------------------------------------------------------------------------
  // Flic2Listener callbacks  (same implementations as the working example)
  // ---------------------------------------------------------------------------

  @override
  void onButtonClicked(Flic2ButtonClick buttonClick) {
    debugPrint('Flic button ${buttonClick.button.uuid} clicked');

    if (!buttonClick.isDoubleClick) {
      _showConnectionConfirmation();
      return;
    }

    final now = DateTime.now();
    if ((_lastAlertTime != null &&
            now.difference(_lastAlertTime!) < _alertCooldown) &&
        _hasActiveTrackingSession) {
      debugPrint('Alert suppressed — cooldown active.');
      return;
    }
    _lastAlertTime = now;
    _sendAlertNow();
  }

  void _showConnectionConfirmation() {
    if (!mounted) return;

    setState(() {
      _isFlicConnected = true;
      _connectedButton = _buttonsFound.values.firstOrNull;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              AppLocalizations.of(context)!.connected,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void onButtonConnected() {
    debugPrint('Flic button connected');

    final alreadyKnown = _buttonsFound.values.firstOrNull;

    if (alreadyKnown != null) {
      setState(() {
        _isFlicConnected = true;
        _connectedButton = alreadyKnown;
      });
    } else {
      // _buttonsFound hasn't been populated yet — fetch directly from SDK
      _flicButtonManager?.getFlic2Buttons().then((buttons) {
        if (!mounted) return;
        final button = buttons.firstOrNull;
        setState(() {
          _isFlicConnected = true;
          _connectedButton = button;
          if (button != null) _buttonsFound[button.uuid] = button;
        });
      });
    }

    _scanController
      ..stop()
      ..reset();
  }

  @override
  void onButtonUpOrDown(Flic2ButtonUpOrDown button) {
    debugPrint('button ${button.button.uuid} ${button.isDown ? 'down' : 'up'}');
  }

  @override
  void onButtonDiscovered(String buttonAddress) {
    debugPrint('button @$buttonAddress discovered');
    _flicButtonManager?.getFlic2ButtonByAddress(buttonAddress).then((button) {
      if (button != null) {
        debugPrint('resolved $buttonAddress → ${button.uuid}');
        _addButtonAndListen(button);
      }
    });
  }

  @override
  void onButtonFound(Flic2Button button) {
    debugPrint('button ${button.uuid} found');
    _addButtonAndListen(button);
  }

  @override
  void onFlic2Error(String error) {
    debugPrint('Flic2 ERROR: $error');
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Button error: $error')));
    }
  }

  @override
  void onPairedButtonDiscovered(Flic2Button button) {
    debugPrint('paired button ${button.uuid} discovered');
    _addButtonAndListen(button);
  }

  @override
  void onScanCompleted() {
    debugPrint('Flic scan completed');
    _scanController
      ..stop()
      ..reset();
    setState(() => _isFlicScanning = false);
  }

  @override
  void onScanStarted() {
    debugPrint('Flic scan started');
    setState(() => _isFlicScanning = true);
  }

  // ---------------------------------------------------------------------------
  // Page init
  // ---------------------------------------------------------------------------

  void _initializePage() async {
    _firstName = AuthService.instance.discretaUser?.firstName;
    final Locale userLocale = Locale(
      AuthService.instance.discretaUser?.language ?? 'fr',
    );
    myAppKey.currentState?.setLocale(userLocale);
    LogService.instance.logInfo('_initializePage was called');
    _checkLocationPermission();
    _checkActiveTrackingSession();
    NotificationService.instance.initialize();
    NotificationService.instance.recordAppOpen();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      LogService.instance.logInfo('Location service is disabled');
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      MessageService.showLocationPermissionDialog(context);
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }

    if (Platform.isIOS) {
      final accuracy = await Geolocator.getLocationAccuracy();
      if (accuracy == LocationAccuracyStatus.reduced) {
        await Geolocator.requestTemporaryFullAccuracy(
          purposeKey: "DiscreteTracking",
        );
      }
    }

    if (permission == LocationPermission.whileInUse) {
      await _requestBackgroundPermission();
    }
  }

  Future<void> _requestBackgroundPermission() async {
    if (Platform.isAndroid) {
      final permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
      }
    }
  }

  void _showBackgroundLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Background location required'),
        content: const Text(
          'Discreta needs to access your location at all times to send '
          'your position when you trigger an alert, even when your screen is locked.\n\n'
          'In the next screen: tap Location → select "Allow all the time".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Protection logic
  // ---------------------------------------------------------------------------

  Future<void> _activateProtection() async {
    final hasTrusted = await _hasTrustedContacts();
    if (!hasTrusted) {
      MessageService.displayAlertDialog(
        context: context,
        title: AppLocalizations.of(context)!.noTrustedContact,
        message: AppLocalizations.of(context)!.pleaseAddContacts,
      );
      return;
    }
    _countdownTimer?.cancel();
    _totalSeconds = _selectedMinutes * 60;
    _remainingSeconds = _totalSeconds;
    _pulseController.repeat(reverse: true);
    setState(() => _isProtectionActive = true);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _isProtectionActive = false;
          _remainingSeconds = 0;
        });
        _sendAlertNow();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  Future<void> _endTrackingSessions() async {
    try {
      await UserService.instance.endTrackingSession();
      setState(() => _hasActiveTrackingSession = false);
    } catch (e) {
      MessageService.displayAlertDialog(
        context: context,
        title: AppLocalizations.of(context)!.unknownError,
        message: AppLocalizations.of(context)!.noInternetConnection,
      );
    }
  }

  Future<void> _checkActiveTrackingSession() async {
    try {
      final hasActiveSession = await UserService.instance
          .hasActiveTrackingSession();
      setState(() => _hasActiveTrackingSession = hasActiveSession);
    } catch (e) {
      MessageService.displayAlertDialog(
        context: context,
        title: AppLocalizations.of(context)!.unknownError,
        message: AppLocalizations.of(context)!.noInternetConnection,
      );
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _deactivateProtection() {
    _countdownTimer?.cancel();
    _pulseController.stop();
    setState(() {
      _isProtectionActive = false;
      _remainingSeconds = 0;
      _totalSeconds = 0;
    });
  }

  Future<bool> _hasTrustedContacts() async {
    final contacts = await UserService.instance.fetchContacts();
    return contacts.isNotEmpty;
  }

  Future<void> _sendAlertNow() async {
    try {
      setState(() => _isLoading = true);
      final hasTrusted = await _hasTrustedContacts();
      if (!hasTrusted) {
        MessageService.displayAlertDialog(
          context: context,
          title: AppLocalizations.of(context)!.noTrustedContact,
          message: AppLocalizations.of(context)!.pleaseAddContacts,
        );
        return;
      }

      if (_hasActiveTrackingSession) {
        await _endTrackingSessions();
      }

      final alertSent = await UserService.instance.sendAlertNow();
      if (!alertSent) {
        MessageService.displayAlertDialog(
          context: context,
          title: AppLocalizations.of(context)!.error,
          message: AppLocalizations.of(context)!.alertNoSent,
        );
        return;
      }
      MessageService.displayAlertDialog(
        context: context,
        title: AppLocalizations.of(context)!.success,
        message: AppLocalizations.of(context)!.alertSent,
      );
      setState(() => _hasActiveTrackingSession = true);
    } catch (e) {
      MessageService.displayAlertDialog(
        context: context,
        title: AppLocalizations.of(context)!.unknownError,
        message: e
            .toString() /*AppLocalizations.of(context)!.noInternetConnection*/,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmSendAlertNow() async {
    MessageService.displayConfirmationDialog(
      context: context,
      onYesPressed: _sendAlertNow,
      message: AppLocalizations.of(context)!.confirmSendAlert,
    );
  }

  String get _countdownLabel =>
      '${AppLocalizations.of(context)!.alertIn} ${_formatTime(_remainingSeconds)}';

  // ---------------------------------------------------------------------------
  // Flic UI widgets
  // ---------------------------------------------------------------------------

  Widget _flicButtonCard(Flic2Button button) {
    return GestureDetector(
      onTap: () {
        _connectButton(button);
        _stopScan();
        setState(() => _showFlicPanel = false);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor.withValues(alpha: 0.12),
              ),
              child: Icon(
                Icons.radio_button_checked,
                color: AppColors.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DiscretaText(
                    text: button.name.isNotEmpty
                        ? button.name
                        : AppLocalizations.of(context)!.safetyDevice,
                    size: TextSize.medium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 2),
                  DiscretaText(
                    text: AppLocalizations.of(context)!.tapToConnect,
                    size: TextSize.small,
                    fontWeight: FontWeight.w300,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _scanningRing() {
    return AnimatedBuilder(
      animation: _scanController,
      builder: (_, __) {
        return Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryColor.withValues(
                alpha: 0.6 - 0.5 * _scanController.value,
              ),
              width: 3,
            ),
          ),
          child: Center(
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor.withValues(alpha: 0.15),
              ),
              child: Icon(
                Icons.bluetooth_searching,
                color: AppColors.primaryColor,
                size: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _statusDot(Color color) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
      ),
      child: Icon(Icons.radio_button_on, color: color, size: 22),
    );
  }

  Widget _flicDeviceCard() {
    final buttons = _buttonsFound.values.toList();

    return FutureBuilder(
      // Wait for the plugin to finish initializing before showing controls.
      future: _flicButtonManager?.invokation,
      builder: (context, snapshot) {
        final bool pluginReady =
            snapshot.connectionState == ConnectionState.done;

        return AnimatedSize(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────────
                Row(
                  children: [
                    if (_isFlicConnected)
                      _statusDot(AppColors.primaryColor)
                    else if (_isFlicScanning)
                      _scanningRing()
                    else
                      _statusDot(Colors.grey.shade400),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DiscretaText(
                            text: AppLocalizations.of(context)!.safetyDevice,
                            size: TextSize.medium,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(height: 3),
                          DiscretaText(
                            text: !pluginReady
                                ? AppLocalizations.of(context)!.initializing
                                : _isFlicConnected
                                ? AppLocalizations.of(context)!.connected
                                : _isFlicScanning
                                ? AppLocalizations.of(context)!.scanning
                                : AppLocalizations.of(context)!.notConnected,
                            size: TextSize.small,
                            fontWeight: FontWeight.w300,
                            color: _isFlicConnected
                                ? AppColors.primaryColor
                                : Colors.grey,
                          ),
                        ],
                      ),
                    ),

                    if (_showFlicPanel || _isFlicConnected)
                      GestureDetector(
                        onTap: _toggleFlicPanel,
                        child: AnimatedRotation(
                          turns: _showFlicPanel ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),

                // ── Expanded panel ────────────────────────────────────────
                if (_showFlicPanel && pluginReady) ...[
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),

                  if (_isFlicConnected) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DiscretaText(
                            text: AppLocalizations.of(
                              context,
                            )!.connectionSuccess,
                            size: TextSize.small,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    DiscretaText(
                      text: AppLocalizations.of(context)!.pairingInstructions,
                      size: TextSize.small,
                      fontWeight: FontWeight.w300,
                    ),
                    const SizedBox(height: 16),

                    if (_isFlicScanning && buttons.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: DiscretaText(
                            text: 'Waiting for nearby buttons…',
                            size: TextSize.small,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isFlicScanning ? _stopScan : _startScan,
                        icon: Icon(
                          _isFlicScanning
                              ? Icons.stop
                              : Icons.bluetooth_searching,
                          size: 18,
                        ),
                        label: Text(
                          _isFlicScanning
                              ? AppLocalizations.of(context)!.stopScanning
                              : AppLocalizations.of(context)!.scanForButton,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFlicScanning
                              ? Colors.grey.shade200
                              : AppColors.primaryColor,
                          foregroundColor: _isFlicScanning
                              ? Colors.grey.shade700
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ] else if (!_showFlicPanel && !_isFlicConnected) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _toggleFlicPanel,
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: AppColors.primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        DiscretaText(
                          text: AppLocalizations.of(context)!.pairButton,
                          size: TextSize.small,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Other card widgets
  // ---------------------------------------------------------------------------

  Widget _shieldIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.withValues(alpha: 0.15),
      ),
      child: const Icon(Icons.shield_outlined, color: Colors.grey, size: 26),
    );
  }

  Widget _pulsingDot() {
    return ScaleTransition(
      scale: Tween(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.red.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  Widget _protectionCard(BuildContext context) {
    final bool isActive = _isProtectionActive && _remainingSeconds > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isActive ? _pulsingDot() : _shieldIcon(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DiscretaText(
                  text: AppLocalizations.of(context)!.protection,
                  size: TextSize.medium,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 6),
                if (isActive) ...[
                  DiscretaText(
                    text: _countdownLabel,
                    size: TextSize.small,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: 1 - (_remainingSeconds / _totalSeconds),
                    backgroundColor: AppColors.primaryColor.withValues(
                      alpha: 0.15,
                    ),
                    color: AppColors.primaryColor,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _safetyTimerCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DiscretaText(
            text: AppLocalizations.of(context)!.safetyTimer,
            size: TextSize.medium,
            fontWeight: FontWeight.w600,
          ),
          DiscretaText(
            text: AppLocalizations.of(context)!.timeBeforeAutomaticAlert,
            size: TextSize.small,
            fontWeight: FontWeight.w100,
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [15, 30, 45, 60].map((minutes) {
              final bool isSelected = _selectedMinutes == minutes;
              return GestureDetector(
                onTap: () => setState(() => _selectedMinutes = minutes),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 18,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (_isProtectionActive
                              ? AppColors.primaryColor.withValues(alpha: 0.3)
                              : AppColors.primaryColor.withValues(alpha: 0.12))
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DiscretaText(
                    text: '$minutes min',
                    size: TextSize.small,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.primaryColor : Colors.black,
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: !_isProtectionActive
                    ? AppColors.primaryColor
                    : AppColors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isProtectionActive
                  ? _deactivateProtection
                  : _activateProtection,
              child: DiscretaText(
                text: _isProtectionActive
                    ? AppLocalizations.of(context)!.stop
                    : AppLocalizations.of(context)!.start,
                size: TextSize.medium,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DiscretaText(
          text: '${AppLocalizations.of(context)!.greeting} $_firstName.',
          size: TextSize.large,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        DiscretaText(
                          text: AppLocalizations.of(
                            context,
                          )!.discretaWelcomeMessage,
                          size: TextSize.medium,
                          fontWeight: FontWeight.bold,
                        ),
                        DiscretaText(
                          text: AppLocalizations.of(
                            context,
                          )!.discretaReassuranceMessage,
                          size: TextSize.medium,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(height: 30.h),
                        _flicDeviceCard(),
                        SizedBox(height: 16.h),
                        _protectionCard(context),
                        SizedBox(height: 30.h),
                        _safetyTimerCard(context),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: DiscretaButton(
                    text: _hasActiveTrackingSession
                        ? AppLocalizations.of(context)!.safetyConfirmed
                        : AppLocalizations.of(context)!.sendAlert,
                    onPressed: () async {
                      if (!_hasActiveTrackingSession) {
                        await _confirmSendAlertNow();
                      } else {
                        await _endTrackingSessions();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading) LoadingOverlay(),
        ],
      ),
    );
  }
}
