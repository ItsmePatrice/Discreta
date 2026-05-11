import 'dart:convert';

import 'package:discreta/app/src/1_Front_end/lib/Classes/discreta_user.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/http_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/log_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Utils/StatusCodes/status_codes.dart';
import 'package:discreta/app/src/1_Front_end/lib/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._privateConstructor();
  static final AuthService _instance = AuthService._privateConstructor();
  static AuthService get instance => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  String? get userFirstName => currentUser?.displayName?.split(' ').first;
  String? _firebaseIdToken;
  String? get firebaseIdToken => _firebaseIdToken;
  DiscretaUser? discretaUser;

  /// Waits for Firebase Auth to restore persisted state, then returns the user.
  Future<User?> get authStateReady async {
    // Wait for Firebase to restore its state
    final user = await _auth.authStateChanges().first;
    if (user != null) return user;

    // Firebase has no user, but Google might still have a cached account
    // Try a silent sign-in to re-link them
    try {
      final isSignedIn = await _googleSignIn.isSignedIn();
      if (!isSignedIn) return null;

      final gUser = await _googleSignIn.signInSilently();
      if (gUser == null) return null;

      final gAuth = await gUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      _firebaseIdToken = await userCredential.user?.getIdToken();
      return userCredential.user;
    } catch (e) {
      LogService.instance.logError('Silent sign-in failed: $e');
      return null;
    }
  }

  // Google sign in
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();
      if (gUser == null) {
        return null;
      }
      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      // create a new credential for the user
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );
      final userCredentials = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      _firebaseIdToken = await userCredentials.user?.getIdToken();
      return userCredentials;
    } catch (e, stackTrace) {
      LogService.instance.logError(
        'Error during Google sign-in',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<DiscretaUser> fetchOrCreateUser() async {
    try {
      final response = await HttpService.instance.post(ApiRoutes.login);
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == StatusCodes.created ||
          response.statusCode == StatusCodes.ok) {
        DiscretaUser user = DiscretaUser.fromJson(responseBody);
        discretaUser = user;
        return user;
      } else {
        String message = responseBody['message'];
        LogService.instance.logWarning(
          "The server responded with status code ${response.statusCode} and message: $message",
        );
        throw Exception(message);
      }
    } catch (e) {
      LogService.instance.logError('Error while fetching or creating user. $e');
      rethrow;
    }
  }

  Future<void> signOutUser() async {
    try {
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      _firebaseIdToken = null;
      discretaUser = null;
    } catch (e, stackTrace) {
      LogService.instance.logError('Error during sign out', e, stackTrace);
      rethrow;
    }
  }
}
