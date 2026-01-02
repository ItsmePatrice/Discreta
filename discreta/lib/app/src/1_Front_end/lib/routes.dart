import 'package:discreta/app/src/1_Front_end/lib/environment.dart';

class ApiRoutes {
  static String baseUrl = AppEnvironment.baseUrl;

  // Auth routes
  static String login = '$baseUrl/api/auth/login';

  // Alert flow
  static String alertMessage = '$baseUrl/api/alert-flow/alert-message';
  static String contacts = '$baseUrl/api/alert-flow/contacts';
  static String sendAlert = '$baseUrl/api/alert-flow/send-alert';

  static String startTrackingSession =
      '$baseUrl/api/alert-flow/start-tracking-session';
  static String endTrackingSession =
      '$baseUrl/api/alert-flow/end-tracking-session';
  static String sendLocationUpdate = '$baseUrl/api/alert-flow/location-update';

  // User routes
  static String language = '$baseUrl/api/user/language';
}
