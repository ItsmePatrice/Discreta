import 'package:discreta/app/src/1_Front_end/lib/environment.dart';

class ApiRoutes {
  static String baseUrl = AppEnvironment.baseUrl;

  // Auth routes
  static String login = '$baseUrl/api/auth/login';
}
