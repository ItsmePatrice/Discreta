import 'dart:convert';

import 'package:discreta/app/src/1_Front_end/Assets/enum/auth_error_codes.dart';
import 'package:discreta/app/src/1_Front_end/Assets/enum/refresh_result.dart';
import 'package:discreta/app/src/1_Front_end/lib/Classes/auth_exception.dart';
import 'package:discreta/app/src/1_Front_end/lib/Classes/discreta_user.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/http_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/log_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/notification_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Utils/StatusCodes/status_codes.dart';
import 'package:discreta/app/src/1_Front_end/lib/routes.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  AuthService._privateConstructor();
  static final AuthService _instance = AuthService._privateConstructor();
  static AuthService get instance => _instance;

  DiscretaUser? discretaUser;
  String? _accessToken;
  String? get accessToken => _accessToken;

  Future<DiscretaUser> fetchOrCreateUser(
    String firstName,
    String email,
    String accessCode,
  ) async {
    try {
      final response = await HttpService.instance.post(ApiRoutes.login, {
        'firstName': firstName,
        'email': email,
        'accessCode': accessCode,
      });
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == StatusCodes.created ||
          response.statusCode == StatusCodes.ok) {
        DiscretaUser user = DiscretaUser.fromJson(responseBody['user']);
        discretaUser = user;
        final refreshToken = responseBody['refresh_token'] as String;
        final accessToken = responseBody['access_token'] as String;
        _accessToken = accessToken;
        await secureWrite('refreshToken', refreshToken);
        await secureWrite('accessToken', accessToken);

        if (response.statusCode == StatusCodes.created) {
          await NotificationService.instance.createUserDocumentForNotifications(
            user.uid,
            user.firstName,
          );
        }
        return user;
      } else {
        String message = responseBody['message'];
        LogService.instance.logWarning(
          "The server responded with status code ${response.statusCode} and message: $message",
        );
        final code = responseBody['code'] as String?;
        LogService.instance.logWarning(
          "Mapping server error code to AuthErrorCode. Server code: $code",
        );
        throw AuthException(_mapErrorCode(code));
      }
    } catch (e) {
      LogService.instance.logError('Error while fetching or creating user. $e');
      rethrow;
    }
  }

  Future<String?> getRefreshToken() async {
    const secureStorage = FlutterSecureStorage(
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
        // This is kSecAttrAccessibleAfterFirstUnlock
      ),
    );
    final refreshToken = await secureStorage.read(key: 'refreshToken');
    return refreshToken;
  }

  Future<RefreshResult> refreshTokens() async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiRoutes.refreshToken),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh_token': await getRefreshToken()}),
          )
          .timeout(const Duration(seconds: 10));
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == StatusCodes.ok) {
        final refreshToken = responseBody['refresh_token'] as String;
        final accessToken = responseBody['access_token'] as String;
        await secureWrite('refreshToken', refreshToken);
        await secureWrite('accessToken', accessToken);
        discretaUser = DiscretaUser.fromJson(responseBody['user']);
        _accessToken = accessToken;
        return RefreshResult.success;
      }

      if (response.statusCode == StatusCodes.unauthorized) {
        LogService.instance.logWarning(
          "Refresh token is invalid or expired. Server responded with status code ${response.statusCode}.",
        );
        await signOutUser();
        return RefreshResult.unauthorized;
      }

      String message = responseBody['message'];
      LogService.instance.logWarning(
        "Failed to refresh tokens. Server responded with status code ${response.statusCode} and message: $message",
      );

      return RefreshResult.serverError;
    } catch (e) {
      LogService.instance.logError('Error while refreshing tokens. $e');
      return RefreshResult.networkError;
    }
  }

  Future<RefreshResult> refreshAccessToken() async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiRoutes.refreshAccessToken),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh_token': await getRefreshToken()}),
          )
          .timeout(const Duration(seconds: 10));
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == StatusCodes.ok) {
        final accessToken = responseBody['access_token'] as String;
        await secureWrite('accessToken', accessToken);
        _accessToken = accessToken;
        return RefreshResult.success;
      }

      if (response.statusCode == StatusCodes.unauthorized) {
        LogService.instance.logWarning(
          "Refresh token is invalid or expired. Server responded with status code ${response.statusCode}.",
        );
        await signOutUser();
        return RefreshResult.unauthorized;
      }

      String message = responseBody['message'];
      LogService.instance.logWarning(
        "Failed to refresh tokens. Server responded with status code ${response.statusCode} and message: $message",
      );

      return RefreshResult.serverError;
    } catch (e) {
      LogService.instance.logError('Error while refreshing tokens. $e');
      return RefreshResult.networkError;
    }
  }

  Future<void> signOutUser() async {
    try {
      // await NotificationService.instance.signOut();
      discretaUser = null;
      const secureStorage = FlutterSecureStorage(
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
          // This is kSecAttrAccessibleAfterFirstUnlock
        ),
      );
      await secureStorage.deleteAll();
    } catch (e, stackTrace) {
      LogService.instance.logError('Error during sign out', e, stackTrace);
      rethrow;
    }
  }

  AuthErrorCode _mapErrorCode(String? code) {
    switch (code) {
      case 'MISSING_FIELDS':
        return AuthErrorCode.missingFields;
      case 'INVALID_CREDENTIALS':
        return AuthErrorCode.invalidCredentials;
      case 'ACCESS_CODE_MAX_USES_OR_INVALID':
        return AuthErrorCode.accessCodeMaxUsesOrInvalid;
      case 'SERVER_ERROR':
        return AuthErrorCode.serverError;
      default:
        return AuthErrorCode.unknown;
    }
  }

  Future<void> secureWrite(String key, String value) async {
    const secureStorage = FlutterSecureStorage(
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
        // This is kSecAttrAccessibleAfterFirstUnlock
      ),
    );
    try {
      await secureStorage.write(key: key, value: value);
    } on PlatformException catch (e) {
      if (e.code == '-25299' || e.message?.contains('already exists') == true) {
        await secureStorage.delete(key: key);
        await secureStorage.write(key: key, value: value);
      } else {
        rethrow;
      }
    }
  }
}
