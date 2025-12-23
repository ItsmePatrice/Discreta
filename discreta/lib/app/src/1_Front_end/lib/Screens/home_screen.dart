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

  @override
  void initState() {
    super.initState();
    initializePage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didPopNext() {
    setState(() {
      _isLoading = true;
    });
    setState(() {
      _isLoading = false;
    });
  }

  void initializePage() async {
    _firstName = AuthService.instance.userFirstName;
    final Locale userLocale = Locale(
      AuthService.instance.discretaUser?.language ?? 'fr',
    );
    myAppKey.currentState?.setLocale(userLocale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DiscretaText(
                        text:
                            '${AppLocalizations.of(context)!.greeting} $_firstName.',
                        size: TextSize.large,
                        fontWeight: FontWeight.bold,
                      ),
                      DiscretaText(
                        text: AppLocalizations.of(
                          context,
                        )!.discretaWelcomeMessage,
                        size: TextSize.small,
                        fontWeight: FontWeight.w300,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
          if (_isLoading) LoadingOverlay(),
        ],
      ),
      bottomNavigationBar: DiscretaNavBar(currentIndex: 0),
    );
  }
}
