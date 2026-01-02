import 'dart:convert';

import 'package:discreta/app/src/1_Front_end/lib/Services/http_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Utils/StatusCodes/status_codes.dart';
import 'package:discreta/app/src/1_Front_end/lib/routes.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  LocationService._privateConstructor();
  static final LocationService _instance =
      LocationService._privateConstructor();
  static LocationService get instance => _instance;

  Future<String> startTrackingSession() async {
    try {
      final response = await HttpService.instance.post(
        ApiRoutes.startTrackingSession,
      );
      if (response.statusCode == StatusCodes.created) {
        final token = jsonDecode(response.body)['trackingToken'];
        return token;
      } else {
        throw Exception(
          'Failed to start tracking session: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error starting tracking session: $e');
    }
  }

  Future<void> sendLocation(String trackingToken, Position position) async {
    try {
      Map<String, dynamic> body = {
        'trackingToken': trackingToken,
        'lat': position.latitude,
        'lng': position.longitude,
      };

      final response = await HttpService.instance.patch(
        ApiRoutes.sendLocationUpdate,
        body,
      );

      if (response.statusCode != StatusCodes.ok) {
        throw Exception(
          'Failed to send location update: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error sending location update: $e');
    }
  }

  Future<void> endTracking() async {
    try {
      await HttpService.instance.post(ApiRoutes.endTrackingSession);
    } catch (e) {
      throw Exception('Error ending tracking session: $e');
    }
  }
}
