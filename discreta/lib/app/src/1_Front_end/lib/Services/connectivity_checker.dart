import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityChecker {
  static Future<bool> hasInternetConnection() async {
    ConnectivityResult result;
    try {
      result = await Connectivity().checkConnectivity();
    } catch (e) {
      return false; // if an error occurs, assume there's no connection
    }

    return result != ConnectivityResult.none; // returns true if user is
    // connected to the internet, else returns false
  }
}
