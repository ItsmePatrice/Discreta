import 'dart:convert';

import 'package:discreta/app/src/1_Front_end/Assets/enum/refresh_result.dart';
import 'package:discreta/app/src/1_Front_end/lib/Classes/discreta_user.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/http_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/log_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Utils/StatusCodes/status_codes.dart';
import 'package:discreta/app/src/1_Front_end/lib/routes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  AuthService._privateConstructor();
  static final AuthService _instance = AuthService._privateConstructor();
  static AuthService get instance => _instance;

  DiscretaUser? discretaUser;

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
        final userJson = responseBody['user'];
        print('uid: ${userJson['uid']}');
        print('first_name: ${userJson['first_name']}');
        print('email: ${userJson['email']}');
        print('language: ${userJson['language']}');
        print('created_at: ${userJson['created_at']}');
        print('updated_at: ${userJson['updated_at']}');
        DiscretaUser user = DiscretaUser.fromJson(responseBody['user']);
        discretaUser = user;
        final refreshToken = responseBody['refresh_token'] as String;
        final accessToken = responseBody['access_token'] as String;
        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(key: 'refreshToken', value: refreshToken);
        await secureStorage.write(key: 'accessToken', value: accessToken);
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

  Future<String?> getAccessToken() async {
    const secureStorage = FlutterSecureStorage();
    final accessToken = await secureStorage.read(key: 'accessToken');
    return accessToken;
  }

  Future<String?> getRefreshToken() async {
    const secureStorage = FlutterSecureStorage();
    final refreshToken = await secureStorage.read(key: 'refreshToken');
    return refreshToken;
  }

  Future<RefreshResult> refreshTokens() async {
    try {
      final response = await HttpService.instance.post(ApiRoutes.refreshToken, {
        'refresh_token': await getRefreshToken(),
      });
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == StatusCodes.ok) {
        final refreshToken = responseBody['refresh_token'] as String;
        final accessToken = responseBody['access_token'] as String;
        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(key: 'refreshToken', value: refreshToken);
        await secureStorage.write(key: 'accessToken', value: accessToken);
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
      discretaUser = null;
      const secureStorage = FlutterSecureStorage();
      await secureStorage.deleteAll();
    } catch (e, stackTrace) {
      LogService.instance.logError('Error during sign out', e, stackTrace);
      rethrow;
    }
  }
}
