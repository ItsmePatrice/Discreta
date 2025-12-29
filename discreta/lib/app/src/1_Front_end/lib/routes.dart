import 'package:discreta/app/src/1_Front_end/lib/environment.dart';

class ApiRoutes {
  static String baseUrl = AppEnvironment.baseUrl;

  // Auth routes
  static String login = '$baseUrl/api/auth/login';

  // Alert flow
  static String alertMessage = '$baseUrl/api/alert-flow/alert-message';
  static String contacts = '$baseUrl/api/alert-flow/contacts';

  // User routes
  static String language = '$baseUrl/api/user/language';
}
