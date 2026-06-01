import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = AppConstants.baseUrl;

  // 0. Send OTP Service
  static Future<Map<String, dynamic>> sendOtp(String mobile) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobile': mobile,
        }),
      );

      print('Send OTP Status: ${response.statusCode}');
      print('Send OTP Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true, 
          'message': data['message'] ?? 'OTP sent successfully',
          'email': data['email']
        };
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to send OTP'};
      }
    } catch (e) {
      print("ApiService SendOtp Error: $e");
      return {'success': false, 'error': 'App Error: $e'};
    }
  }

  // 1. Login Service
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Save user session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data['data']));
        await prefs.setString('party_id', data['data']['partyId']); // Fixed path
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Login failed'};
      }
    } catch (e) {
      print("ApiService Error: $e"); // Log the real error
      return {'success': false, 'error': 'App Error: $e'};
    }
  }

  //  2.Get Dashboard Data
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final partyId = prefs.getString('party_id');

      if (partyId == null) return {'success': false, 'error': 'Session expired'};

      final response = await http.get(Uri.parse('$baseUrl/dashboard?partyId=$partyId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': 'Failed to load dashboard'};
    }
  }

  //3. Get Stock List
  static Future<Map<String, dynamic>> getStock({String query = ""}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final partyId = prefs.getString('party_id');

      if (partyId == null) return {'success': false, 'error': 'Session expired'};

      final response = await http.get(Uri.parse('$baseUrl/stock?partyId=$partyId&query=$query'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': 'Failed to load stock'};
    }
  }

  //4. Get Ledger Statement
  static Future<Map<String, dynamic>> getLedger() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final partyId = prefs.getString('party_id');

      if (partyId == null) return {'success': false, 'error': 'Session expired'};

      final response = await http.get(Uri.parse('$baseUrl/ledger?partyId=$partyId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': 'Failed to load ledger'};
    }
  }

  //5. Get Demand History
  static Future<Map<String, dynamic>> getDemands() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final partyId = prefs.getString('party_id');
      if (partyId == null) return {'success': false, 'error': 'Session expired'};

      final response = await http.get(Uri.parse('$baseUrl/demand?partyId=$partyId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': 'Failed to load demands'};
    }
  }

  //6. Get Available Stock for Demand
  static Future<Map<String, dynamic>> getAvailableStockForDemand() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final partyId = prefs.getString('party_id');
      if (partyId == null) return {'success': false, 'error': 'Session expired'};

      final response = await http.get(Uri.parse('$baseUrl/demand/available-stock?partyId=$partyId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': 'Failed to load available stock'};
    }
  }

  //7. Create New Demand
  static Future<Map<String, dynamic>> createDemand(List<Map<String, dynamic>> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final partyId = prefs.getString('party_id');
      if (partyId == null) return {'success': false, 'error': 'Session expired'};

      final response = await http.post(
        Uri.parse('$baseUrl/demand'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'partyId': partyId,
          'date': DateTime.now().toIso8601String(),
          'items': items,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': 'Failed to create demand'};
    }
  }

  //9. Get Notifications
  static Future<Map<String, dynamic>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final partyId = prefs.getString('party_id');
      if (partyId == null) return {'success': false, 'error': 'Session expired'};

      final response = await http.get(Uri.parse('$baseUrl/notifications?partyId=$partyId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': 'Failed to load notifications'};
    }
  }

  //10. Mark Notifications as Read
  static Future<Map<String, dynamic>> markNotificationsAsRead({String? id}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final partyId = prefs.getString('party_id');
      if (partyId == null) return {'success': false, 'error': 'Session expired'};

      final response = await http.post(
        Uri.parse('$baseUrl/notifications'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'partyId': partyId,
          'notificationId': id,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': 'Failed to update notifications'};
    }
  }

  //11. Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  //12. Delete Account
  static Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final partyId = prefs.getString('party_id');
      if (partyId == null) return {'success': false, 'error': 'Session expired'};

      final response = await http.post(
        Uri.parse('$baseUrl/auth/delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'partyId': partyId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await prefs.clear();
        return {'success': true};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to delete account'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to delete account: $e'};
    }
  }
}
