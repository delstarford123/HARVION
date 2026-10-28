import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Automatically switches between production subdomain and local dev
  String get baseUrl => kReleaseMode
      ? AppConstants.backendProductionUrl
      : AppConstants.backendApiUrl;

  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health')).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'status': 'offline', 'error': 'Non-200 status code'};
    } catch (e) {
      return {'status': 'offline', 'error': e.toString()};
    }
  }

  Future<List<dynamic>> getBooks({String? category, String? search}) async {
    try {
      final uri = Uri.parse('$baseUrl/books').replace(queryParameters: {
        if (category != null && category != 'All Categories') 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['data'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> triggerMpesaStkPush({
    required String phone,
    required double amount,
    required String orderId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/stk-push'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': phone,
          'amount': amount,
          'orderId': orderId,
          'accountReference': 'HARVION',
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> verifyColporteurCode(String code) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/colporteurs/$code'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

