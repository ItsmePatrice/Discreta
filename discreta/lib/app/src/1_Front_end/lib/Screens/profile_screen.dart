import 'dart:async';

import 'package:discreta/app/src/1_Front_end/Assets/colors.dart';
import 'package:discreta/app/src/1_Front_end/Assets/enum/text_size.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/Layout/discreta_nav_bar.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/discreta_text.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/loading_overlay.dart';
import 'package:discreta/app/src/1_Front_end/lib/Screens/login_screen.dart';
import 'package:discreta/app/src/1_Front_end/lib/Screens/settings_screen.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/auth_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/message_service.dart';
import 'package:discreta/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfilePage> {
  bool _isLoading = false;

  late final StreamSubscription<Map<String, dynamic>> _subscription;

  @override
  void initState() {}

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _signUserOut() async {
    try {
      await AuthService.instance.signOutUser();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      MessageService.displayAlertDialog(
        context: context,
        title: AppLocalizations.of(context)!.unknownError,
        message: AppLocalizations.of(context)!.noInternetConnection,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: DiscretaText(
          text: AppLocalizations.of(context)!.profile,
          fontWeight: FontWeight.bold,
          size: TextSize.medium,
          color: Colors.white,
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /* ListTile(
                        leading: Icon(Icons.payment),
                        title: Text('Payment method'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PaymentMethodsPage(),
                          ),
                        ),
                      ), */
                      // use when setting up subsciption flow
                      ListTile(
                        leading: Icon(Icons.settings),
                        title: Text(AppLocalizations.of(context)!.settings),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text(AppLocalizations.of(context)!.signOut),
                        onTap: _signUserOut,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_isLoading) LoadingOverlay(),
        ],
      ),
      bottomNavigationBar: DiscretaNavBar(currentIndex: 3),
    );
  }
}
