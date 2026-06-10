import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:discreta/app/src/1_Front_end/lib/Services/auth_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Utils/StatusCodes/status_codes.dart';
import 'package:discreta/app/src/1_Front_end/Assets/enum/refresh_result.dart';

class HttpService {
  HttpService._privateConstructor();
  static final HttpService _instance = HttpService._privateConstructor();
  static HttpService get instance => _instance;

  Future<void>? _refreshFuture;

  static const Duration _requestTimeout = Duration(seconds: 10);

  Future<http.Response> _requestWithAuth(
    Future<http.Response> Function(String? token) request,
  ) async {
    final token = AuthService.instance.accessToken;

    http.Response response = await request(token).timeout(_requestTimeout);

    // If not unauthorized → return immediately
    if (response.statusCode != StatusCodes.unauthorized) {
      return response;
    }

    // Try refresh once (safe shared lock)
    final refreshed = await _refreshTokenSafely();

    if (!refreshed) {
      throw Exception('Authentication failed. User must re-login.');
    }

    // Retry request once with new token
    final newToken = AuthService.instance.accessToken;

    final retryResponse = await request(newToken).timeout(_requestTimeout);

    // IMPORTANT: final guard
    if (retryResponse.statusCode == StatusCodes.unauthorized) {
      throw Exception('Authentication expired after retry.');
    }

    return retryResponse;
  }

  Future<bool> _refreshTokenSafely() async {
    // If refresh already running → wait for it
    if (_refreshFuture != null) {
      await _refreshFuture;
      return AuthService.instance.accessToken != null;
    }

    final completer = Completer<void>();
    _refreshFuture = completer.future;

    try {
      final result = await AuthService.instance.refreshAccessToken();

      completer.complete();

      return result == RefreshResult.success;
    } catch (e) {
      completer.complete();
      return false;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<http.Response> get(String path, [Map<String, dynamic>? data]) {
    return _requestWithAuth((token) async {
      Uri url = Uri.parse(path);

      if (data != null && data.isNotEmpty) {
        url = url.replace(
          queryParameters: data.map((k, v) => MapEntry(k, v.toString())),
        );
      }

      return await http.get(url, headers: _headers(token));
    });
  }

  Future<http.Response> post(String path, [Map<String, dynamic>? data]) {
    return _requestWithAuth((token) async {
      return await http.post(
        Uri.parse(path),
        headers: _headers(token),
        body: data != null ? jsonEncode(data) : null,
      );
    });
  }

  Future<http.Response> patch(String path, [Map<String, dynamic>? data]) {
    return _requestWithAuth((token) async {
      return await http.patch(
        Uri.parse(path),
        headers: _headers(token),
        body: data != null ? jsonEncode(data) : null,
      );
    });
  }

  Future<http.Response> put(String path, [Map<String, dynamic>? data]) {
    return _requestWithAuth((token) async {
      return await http.put(
        Uri.parse(path),
        headers: _headers(token),
        body: data != null ? jsonEncode(data) : null,
      );
    });
  }

  Future<http.Response> delete(String path, [Map<String, dynamic>? data]) {
    return _requestWithAuth((token) async {
      return await http.delete(
        Uri.parse(path),
        headers: _headers(token),
        body: data != null ? jsonEncode(data) : null,
      );
    });
  }

  Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
