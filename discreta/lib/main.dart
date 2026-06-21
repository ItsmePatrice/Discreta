import 'package:discreta/app/src/1_Front_end/Assets/enum/refresh_result.dart';
import 'package:discreta/app/src/1_Front_end/lib/Screens/login_screen.dart';
import 'package:discreta/app/src/1_Front_end/lib/Screens/main_shell.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/auth_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/connectivity_checker.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/message_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Utils/StatusCodes/page_transition_builder.dart';
import 'package:discreta/firebase_options.dart';
import 'package:discreta/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

GlobalKey<_MyAppState> myAppKey = GlobalKey<_MyAppState>();

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
// ── Top-level background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register background handler BEFORE runApp
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
          theme: ThemeData(
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                for (var platform in TargetPlatform.values)
                  platform: NoAnimationPageTransitionsBuilder(),
              },
            ),
          ),
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
  bool _hasCheckedConnectivity = false;
  bool _isConnected = false;
  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    _isConnected = await ConnectivityChecker.hasInternetConnection();
    if (!mounted) return;
    setState(() {
      _hasCheckedConnectivity = true;
    });
    if (_isConnected) {
      await _checkAuth();
    }
  }

  Future<void> _checkAuth() async {
    const storage = FlutterSecureStorage(
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
        // This is kSecAttrAccessibleAfterFirstUnlock
      ),
    );
    final refreshToken = await storage.read(key: 'refreshToken');

    if (!mounted) return;

    if (refreshToken == null) {
      setState(() {
        _isAuthenticated = false;
        _isCheckingAuth = false;
      });
      return;
    }

    final RefreshResult refreshResult = await AuthService.instance
        .refreshTokens();

    switch (refreshResult) {
      case RefreshResult.success:
        setState(() {
          _isAuthenticated = true;
          _isCheckingAuth = false;
        });
        break;

      case RefreshResult.unauthorized:
        await AuthService.instance.signOutUser();
        setState(() {
          _isAuthenticated = false;
          _isCheckingAuth = false;
        });
        break;

      case RefreshResult.networkError:
      case RefreshResult.serverError:
        setState(() {
          _isAuthenticated = false;
          _isCheckingAuth = false;
        });
        _showNoConnectionDialog();
        break;
    }
  }

  void _showNoConnectionDialog() {
    if (!mounted) return;
    MessageService.displayNoConnectionDialog(
      context: context,
      title: AppLocalizations.of(context)!.noInternetTitle,
      message: AppLocalizations.of(context)!.noInternetConnection,
      buttonText: AppLocalizations.of(context)!.retry,
      onRetry: () async {
        setState(() {
          _hasCheckedConnectivity = false;
        });
        await _checkConnectivity();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasCheckedConnectivity || _isCheckingAuth) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (!_isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNoConnectionDialog();
      });
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (_isAuthenticated) {
      return const MainShell();
    } else {
      return const LoginPage();
    }
  }
}
