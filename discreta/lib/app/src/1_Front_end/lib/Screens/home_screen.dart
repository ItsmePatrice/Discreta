import 'dart:async';
import 'package:discreta/app/src/1_Front_end/lib/Services/flic_service.dart';
import 'package:flic_button/flic_button.dart';
import 'package:discreta/app/src/1_Front_end/Assets/colors.dart';
import 'package:discreta/app/src/1_Front_end/Assets/enum/text_size.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/discreta_button.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/discreta_text.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/loading_overlay.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/auth_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/message_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/user_service.dart';
import 'package:discreta/l10n/app_localizations.dart';
import 'package:discreta/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with RouteAware, TickerProviderStateMixin {
  String? _firstName;
  bool _isLoading = false;

  bool _isProtectionActive = false;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  Timer? _countdownTimer;
  int _selectedMinutes = 15;

  bool _hasActiveTrackingSession = false;

  // Flic state
  bool _isFlicScanning = false;
  bool _isFlicConnected = false;
  bool _showFlicPanel = false;

  late AnimationController _pulseController;
  late AnimationController _scanController;

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

    // Listen to FlicService so the UI rebuilds on any connection/discovery change.
    FlicService.instance.addListener(_onFlicStateChanged);

    initializePage();
    FlicService.instance.init();
  }

  @override
  void dispose() {
    FlicService.instance.removeListener(_onFlicStateChanged);
    _pulseController.dispose();
    _scanController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Flic state sync
  // ---------------------------------------------------------------------------

  void _onFlicStateChanged() {
    if (!mounted) return;
    setState(() {
      _isFlicConnected = FlicService.instance.isConnected;
      _isFlicScanning = FlicService.instance.isScanning;

      // Auto-stop scan animation once connected.
      if (_isFlicConnected) {
        _scanController.stop();
        _scanController.reset();
      }
    });

    // Surface any SDK error as a snackbar.
    final error = FlicService.instance.lastError;
    if (error != null) {
      FlicService.instance.lastError = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Button error: $error')));
        }
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Flic scan helpers
  // ---------------------------------------------------------------------------

  void _startScan() {
    FlicService.instance.startScan();
    _scanController.repeat();
    setState(() {
      _isFlicScanning = true;
      _showFlicPanel = true;
    });
  }

  void _stopScan() {
    FlicService.instance.stopScan();
    _scanController.stop();
    _scanController.reset();
    setState(() => _isFlicScanning = false);
  }

  void _toggleFlicPanel() {
    setState(() => _showFlicPanel = !_showFlicPanel);
  }

  // ---------------------------------------------------------------------------
  // Page init
  // ---------------------------------------------------------------------------

  void initializePage() async {
    _firstName = AuthService.instance.userFirstName;
    await AuthService.instance.fetchOrCreateUser();
    final Locale userLocale = Locale(
      AuthService.instance.discretaUser?.language ?? 'fr',
    );
    myAppKey.currentState?.setLocale(userLocale);
    _checkLocationPermission();
    _checkActiveTrackingSession();
  }

  Future<void> _checkLocationPermission() async {
    try {
      await UserService.instance.ensureLocationPermission();
    } catch (e) {
      MessageService.showLocationPermissionDialog(context);
    }
  }

  // ---------------------------------------------------------------------------
  // Protection logic
  // ---------------------------------------------------------------------------

  Future<void> _activateProtection() async {
    final hasTrustedContacts = await this.hasTrustedContacts();
    if (!hasTrustedContacts) {
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

  Future<bool> hasTrustedContacts() async {
    final trustedContacts = await UserService.instance.fetchContacts();
    return trustedContacts.isNotEmpty;
  }

  Future<void> _sendAlertNow() async {
    try {
      setState(() => _isLoading = true);
      final hasTrustedContacts = await this.hasTrustedContacts();
      if (!hasTrustedContacts) {
        MessageService.displayAlertDialog(
          context: context,
          title: AppLocalizations.of(context)!.noTrustedContact,
          message: AppLocalizations.of(context)!.pleaseAddContacts,
        );
        return;
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
        message: AppLocalizations.of(context)!.noInternetConnection,
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
        FlicService.instance.connect(button);
        FlicService.instance.listen(button);
        _stopScan();
        // _isFlicConnected flips via _onFlicStateChanged once onButtonConnected fires.
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
                        : 'Safety button',
                    size: TextSize.medium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 2),
                  DiscretaText(
                    text: 'Tap to connect',
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

  Widget _flicDeviceCard() {
    // Merge previously-paired and newly discovered buttons, deduplicated by uuid.
    final seen = <String>{};
    final buttons = [
      ...FlicService.instance.pairedButtons,
      ...FlicService.instance.discoveredButtons,
    ].where((b) => seen.add(b.uuid)).toList();

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
            // ── Header ──────────────────────────────────────────────────────
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
                        text: 'Safety Button',
                        size: TextSize.medium,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 3),
                      DiscretaText(
                        text: _isFlicConnected
                            ? 'Connected'
                            : _isFlicScanning
                            ? 'Scanning for buttons…'
                            : 'Not connected',
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

            // ── Expanded panel ───────────────────────────────────────────────
            if (_showFlicPanel) ...[
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
                        text:
                            'Your button is connected and will trigger an alert when pressed.',
                        size: TextSize.small,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      FlicService.instance.disconnect();
                      setState(() => _showFlicPanel = false);
                    },
                    icon: const Icon(Icons.link_off, size: 18),
                    label: const Text('Disconnect button'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                DiscretaText(
                  text:
                      'Hold your button for 7 seconds to put it in\n'
                      'pairing mode, then press Scan.',
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
                  )
                else if (buttons.isNotEmpty)
                  ...buttons.map((b) => _flicButtonCard(b)),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isFlicScanning ? _stopScan : _startScan,
                    icon: Icon(
                      _isFlicScanning ? Icons.stop : Icons.bluetooth_searching,
                      size: 18,
                    ),
                    label: Text(
                      _isFlicScanning ? 'Stop scanning' : 'Scan for button',
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
                      text: 'Pair button',
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

  Widget protectionCard(BuildContext context) {
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

  Widget safetyTimerCard(BuildContext context) {
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
                        protectionCard(context),
                        SizedBox(height: 30.h),
                        safetyTimerCard(context),
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
