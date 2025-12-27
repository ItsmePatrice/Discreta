import 'dart:async';

import 'package:discreta/app/src/1_Front_end/Assets/colors.dart';
import 'package:discreta/app/src/1_Front_end/Assets/enum/text_size.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/Layout/discreta_nav_bar.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/discreta_text.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/loading_overlay.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/auth_service.dart';
import 'package:discreta/l10n/app_localizations.dart';
import 'package:discreta/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  String? _firstName;
  bool _isLoading = false;

  // Protection state
  bool _isProtectionActive = false;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  Timer? _countdownTimer;
  int _selectedMinutes = 15;

  @override
  void initState() {
    super.initState();
    initializePage();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void initializePage() async {
    _firstName = AuthService.instance.userFirstName;
    final Locale userLocale = Locale(
      AuthService.instance.discretaUser?.language ?? 'fr',
    );
    myAppKey.currentState?.setLocale(userLocale);
  }

  void _activateProtection() {
    _countdownTimer?.cancel();

    _totalSeconds = _selectedMinutes * 60;
    _remainingSeconds = _totalSeconds;

    setState(() {
      _isProtectionActive = true;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
        });
        // Protection finished / trigger action here (send alerts)
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _deactivateProtection() {
    _countdownTimer?.cancel();

    setState(() {
      _isProtectionActive = false;
      _remainingSeconds = 0;
      _totalSeconds = 0;
    });
  }

  Widget braceletStatusCard({
    required BuildContext context,
    required bool isConnected,
  }) {
    final Color statusColor = isConnected
        ? AppColors.primaryColor
        : const Color.fromARGB(255, 134, 129, 122);
    final IconData statusIcon = isConnected
        ? Icons.bluetooth_connected
        : Icons.bluetooth_disabled;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DiscretaText(
                  text: AppLocalizations.of(context)!.status,
                  size: TextSize.medium,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 4),
                DiscretaText(
                  text: isConnected
                      ? AppLocalizations.of(context)!.connected
                      : AppLocalizations.of(context)!.notConnected,
                  size: TextSize.small,
                  fontWeight: FontWeight.w300,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget protectionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DiscretaText(
            text: AppLocalizations.of(context)!.protection,
            size: TextSize.medium,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 12.h),

          if (_isProtectionActive && _remainingSeconds > 0) ...[
            DiscretaText(
              text: AppLocalizations.of(context)!.alertIn,
              size: TextSize.small,
              fontWeight: FontWeight.w400,
            ),
            SizedBox(height: 16.h),
            animatedCountdown(context),
            SizedBox(height: 20.h),
            LinearProgressIndicator(
              value: 1 - (_remainingSeconds / _totalSeconds),
              backgroundColor: AppColors.primaryColor.withValues(alpha: 0.15),
              color: AppColors.primaryColor,
              minHeight: 6,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ],
      ),
    );
  }

  Widget animatedCountdown(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Center(
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryColor.withValues(alpha: 0.15),
          ),
          alignment: Alignment.center,
          child: DiscretaText(
            text: _formatTime(_remainingSeconds),
            size: TextSize.large,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
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
          SizedBox(height: 16.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [15, 30, 45, 60].map((minutes) {
              final bool isSelected = _selectedMinutes == minutes;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMinutes = minutes;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 18,
                  ),
                  decoration: BoxDecoration(
                    color: _isProtectionActive
                        ? AppColors.primaryColor.withValues(alpha: 0.3)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DiscretaText(
                    text: '$minutes min',
                    size: TextSize.small,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
                    : AppLocalizations.of(context)!.activateProtection,
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),

                  DiscretaText(
                    text: AppLocalizations.of(context)!.discretaWelcomeMessage,
                    size: TextSize.small,
                    fontWeight: FontWeight.w300,
                  ),
                  SizedBox(height: 30.h),
                  braceletStatusCard(context: context, isConnected: true),
                  SizedBox(height: 30.h),
                  protectionCard(context),
                  SizedBox(height: 30.h),
                  safetyTimerCard(context),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
          if (_isLoading) LoadingOverlay(),
        ],
      ),
      // bottomNavigationBar: DiscretaNavBar(currentIndex: 0),
    );
  }
}
