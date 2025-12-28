import 'dart:convert';

import 'package:discreta/app/src/1_Front_end/lib/Classes/contact.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/http_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/log_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Utils/StatusCodes/status_codes.dart';
import 'package:discreta/app/src/1_Front_end/lib/routes.dart';

class UserService {
  UserService._privateConstructor();
  static final UserService _instance = UserService._privateConstructor();
  static UserService get instance => _instance;

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
}
