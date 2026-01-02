import 'dart:async';
import 'dart:convert';

import 'package:discreta/app/src/1_Front_end/lib/Classes/contact.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/auth_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/http_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/location_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/log_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Utils/StatusCodes/status_codes.dart';
import 'package:discreta/app/src/1_Front_end/lib/routes.dart';
import 'package:geolocator/geolocator.dart';

class UserService {
  UserService._privateConstructor();
  static final UserService _instance = UserService._privateConstructor();
  static UserService get instance => _instance;
  StreamSubscription<Position>? positionStream;
  Timer? _autoStopTimer;

  Future<void> saveAlertMessage(String messageContent) async {
    try {
      final data = {'message': messageContent};
      final response = await HttpService.instance.put(
        ApiRoutes.alertMessage,
        data,
      );
      if (response.statusCode != StatusCodes.ok) {
        throw Exception('Failed to save alert message');
      }
    } catch (e) {
      LogService.instance.logError('Error saving alert message', e);
      rethrow;
    }
  }

  void _startAutoStopTimer() {
    _autoStopTimer?.cancel();

    _autoStopTimer = Timer(const Duration(hours: 2), () async {
      await endLocationUpdates();
    });
  }

  Future<String?> fetchAlertMessage() async {
    try {
      final response = await HttpService.instance.get(ApiRoutes.alertMessage);
      if (response.statusCode == StatusCodes.ok) {
        final responseBody = jsonDecode(response.body);
        return responseBody['message'] as String;
      } else if (response.statusCode == StatusCodes.notFound) {
        return null;
      } else {
        throw Exception('Failed to fetch alert message');
      }
    } catch (e) {
      LogService.instance.logError('Error fetching alert message', e);
      rethrow;
    }
  }

  Future<List<Contact>> fetchContacts() async {
    try {
      final response = await HttpService.instance.get(ApiRoutes.contacts);
      if (response.statusCode == StatusCodes.ok) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (responseBody['contacts'] as List<dynamic>)
            .map((contactJson) => Contact.fromJson(contactJson))
            .toList();
        return list;
      } else {
        throw Exception('Failed to fetch contacts');
      }
    } catch (e) {
      LogService.instance.logError('Error fetching contacts', e);
      rethrow;
    }
  }

  Future<void> addContact(Contact contact) async {
    try {
      final data = {'name': contact.name, 'phoneNumber': contact.phone};
      final response = await HttpService.instance.post(
        ApiRoutes.contacts,
        data,
      );
      if (response.statusCode != StatusCodes.created) {
        throw Exception('Failed to add contact');
      }
    } catch (e) {
      LogService.instance.logError('Error adding contact', e);
      rethrow;
    }
  }

  Future<void> deleteContact(String contactId) async {
    try {
      final response = await HttpService.instance.delete(
        '${ApiRoutes.contacts}/$contactId',
      );
      if (response.statusCode != StatusCodes.ok) {
        throw Exception('Failed to delete contact');
      }
    } catch (e) {
      LogService.instance.logError('Error deleting contact', e);
      rethrow;
    }
  }

  Future<void> updateContact(Contact contact) async {
    try {
      final data = {'name': contact.name, 'phoneNumber': contact.phone};
      final String contactId = contact.id!;
      final response = await HttpService.instance.put(
        '${ApiRoutes.contacts}/$contactId',
        data,
      );
      if (response.statusCode != StatusCodes.ok) {
        throw Exception('Failed to update contact');
      }
    } catch (e) {
      LogService.instance.logError('Error updating contact', e);
      rethrow;
    }
  }

  Future<void> setLanguagePreference(String languageCode) async {
    try {
      final data = {'language': languageCode};
      final response = await HttpService.instance.patch(
        ApiRoutes.language,
        data,
      );
      if (response.statusCode != StatusCodes.ok) {
        throw Exception('Failed to set language preference');
      }
      final responseBody = jsonDecode(response.body);
      final updatedLanguage = responseBody['language'] as String;
      AuthService.instance.discretaUser?.language = updatedLanguage;
    } catch (e) {
      LogService.instance.logError('Error setting language preference', e);
      rethrow;
    }
  }

  Future<void> ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied by user.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission permanently denied. Please enable it in settings.',
      );
    }
  }

  // Make sure you capture the user's current location first
  Future<void> _startLocationUpdates(String trackingToken) async {
    try {
      final Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      await LocationService.instance.sendLocation(
        trackingToken,
        initialPosition,
      );

      positionStream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
              distanceFilter: 5, // meters
            ),
          ).listen((Position position) {
            try {
              LocationService.instance.sendLocation(trackingToken, position);
            } catch (e) {
              LogService.instance.logError('Error sending location update', e);
            }
          });
    } catch (e) {
      LogService.instance.logError('Error starting location updates. $e');
      rethrow;
    }
  }

  // call this method when the user clicks on "I'm safe" after an alert has been sent
  Future<void> endLocationUpdates() async {
    try {
      await positionStream?.cancel();
      positionStream = null;
      await LocationService.instance.endTracking();
    } catch (e) {
      LogService.instance.logError('Error ending location updates', e);
      rethrow;
    }
  }

  // When the app loads, if the user hasn't given location tracking permission to the app, ask it.
  // The user should only be able to use the app if they accept giving location permission.
  Future<bool> sendAlertNow() async {
    try {
      final trackingToken = await LocationService.instance
          .startTrackingSession();
      await _startLocationUpdates(trackingToken);
      _startAutoStopTimer();
      final response = await HttpService.instance.post(ApiRoutes.sendAlert);
      if (response.statusCode != StatusCodes.ok) {
        throw Exception(
          'Failed to send alert now. ${jsonDecode(response.body)['message']}',
        );
      }
      final responseBody = jsonDecode(response.body);
      return responseBody['sentAlert'] as bool;
    } catch (e) {
      LogService.instance.logError('Error sending alert now', e);
      rethrow;
    }
  }
}
