import 'package:discreta/app/src/1_Front_end/Assets/colors.dart';
import 'package:discreta/app/src/1_Front_end/lib/Screens/home_screen.dart';
import 'package:discreta/app/src/1_Front_end/lib/Screens/login_screen.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/auth_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/connectivity_checker.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/message_service.dart';
import 'package:discreta/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'firebase_options.dart';

// Global key to control MyApp state (for changing locale)
GlobalKey<_MyAppState> myAppKey = GlobalKey<_MyAppState>();

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp(key: myAppKey));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('fr');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('language', locale.languageCode);
    });
  }

  String currentLanguage() => _locale.languageCode;

  void setLanguage(String code) {
    final lang = (code == 'en') ? 'en' : 'fr';
    myAppKey.currentState?.setLocale(Locale(lang));
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Discreta',
          locale: _locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('fr')],
          navigatorObservers: [routeObserver],
          home: const SplashPage(),
        );
      },
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => initializeApp());
  }

  Future<void> initializeApp() async {
    bool isConnected = await ConnectivityChecker.hasInternetConnection();

    if (!isConnected) {
      if (mounted) {
        MessageService.displayNoConnectionDialog(
          context: context,
          title: AppLocalizations.of(context)!.noInternetTitle,
          message: AppLocalizations.of(context)!.noInternetConnection,
          buttonText: AppLocalizations.of(context)!.retry,
          onRetry: () async {
            initializeApp();
          },
        );
      }
      return;
    }

    bool isSignedIn = AuthService.instance.currentUser != null;
    if (!isSignedIn) {
      safePushReplacement(const LoginPage());
    } else {
      safePushReplacement(const HomePage());
    }
  }

  void safePushReplacement(Widget page) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => page));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
