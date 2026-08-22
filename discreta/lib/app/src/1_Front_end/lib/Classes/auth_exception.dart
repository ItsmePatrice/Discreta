import 'package:discreta/app/src/1_Front_end/Assets/enum/auth_error_codes.dart';

class AuthException implements Exception {
  final AuthErrorCode code;
  AuthException(this.code);
}
