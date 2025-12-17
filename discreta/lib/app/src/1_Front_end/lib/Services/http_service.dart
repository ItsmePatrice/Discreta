import 'dart:convert';

import 'package:discreta/app/src/1_Front_end/lib/Services/auth_service.dart';
import 'package:http/http.dart' as http;

class HttpService {
  HttpService._privateConstructor();
  static final HttpService _instance = HttpService._privateConstructor();
  static HttpService get instance => _instance;

  Future<http.Response> get(String path, [Map<String, dynamic>? data]) async {
    try {
      final firebaseToken = await AuthService.instance.currentUser
          ?.getIdToken();

      Uri url = Uri.parse(path);
      if (data != null && data.isNotEmpty) {
        url = url.replace(
          queryParameters: data.map((k, v) => MapEntry(k, v.toString())),
        );
      }
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (firebaseToken != null) 'Authorization': 'Bearer $firebaseToken',
        },
      );
      return response;
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  Future<http.Response> post(String path, [Map<String, dynamic>? data]) async {
    try {
      final firebaseToken = await AuthService.instance.currentUser
          ?.getIdToken();
      if (firebaseToken == null) {
        throw ("Could not process request: Firebase token is null");
      }

      final url = Uri.parse(path);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $firebaseToken',
        },
        body: data != null ? jsonEncode(data) : null,
      );
      return response;
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  Future<http.Response> patch(String path, [Map<String, dynamic>? data]) async {
    try {
      final firebaseToken = await AuthService.instance.currentUser
          ?.getIdToken();
      if (firebaseToken == null) {
        throw ("Could not process request: Firebase token is null");
      }

      final url = Uri.parse(path);
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $firebaseToken',
        },
        body: data != null ? jsonEncode(data) : null,
      );
      return response;
    } catch (e) {
      throw Exception('PATCH request failed: $e');
    }
  }

  Future<http.Response> put(String path, [Map<String, dynamic>? data]) async {
    try {
      final firebaseToken = await AuthService.instance.currentUser
          ?.getIdToken();
      if (firebaseToken == null) {
        throw ("Could not process request: Firebase token is null");
      }

      final url = Uri.parse(path);
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $firebaseToken',
        },
        body: data != null ? jsonEncode(data) : null,
      );
      return response;
    } catch (e) {
      throw Exception('PUT request failed: $e');
    }
  }

  Future<http.Response> delete(
    String path, [
    Map<String, dynamic>? data,
  ]) async {
    try {
      final firebaseToken = await AuthService.instance.currentUser
          ?.getIdToken();
      if (firebaseToken == null) {
        throw ("Could not process request: Firebase token is null");
      }

      final url = Uri.parse(path);
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $firebaseToken',
        },
        body: data != null ? jsonEncode(data) : null,
      );
      return response;
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }
}
