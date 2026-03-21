import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  // REGISTER
  static Future register(name, email, phone, address, password) async {
    var res = await http.post(
      Uri.parse("${AppConstants.baseUrl}/auth/register.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "phone": phone,
        "address": address,
        "password": password,
      }),
    );
    return jsonDecode(res.body);
  }

  // VERIFY OTP
  static Future verifyOtp(email, otp) async {
    var res = await http.post(
      Uri.parse("${AppConstants.baseUrl}/auth/verify_otp.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );
    return jsonDecode(res.body);
  }

  // FORGOT PASSWORD
  static Future forgotPassword(email) async {
    var res = await http.post(
      Uri.parse("${AppConstants.baseUrl}/auth/forgot_password.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    print("RAW RESPONSE: ${res.body}");

    return jsonDecode(res.body);
  }

  // RESET PASSWORD
  static Future resetPassword(email, otp, password) async {
    var res = await http.post(
      Uri.parse("${AppConstants.baseUrl}/auth/reset_password.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp, "password": password}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    var res = await http.post(
      Uri.parse("${AppConstants.baseUrl}/auth/login.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    return jsonDecode(res.body);
  }

  static Future<List> getProducts() async {
    var res = await http.get(
      Uri.parse("${AppConstants.baseUrl}/products/get_products.php"),
    );
    return jsonDecode(res.body);
  }

  static Future<List> getOrders() async {
    var res = await http.get(
      Uri.parse("${AppConstants.baseUrl}/orders/get_my_orders.php"),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> placeOrder(List items) async {
    var res = await http.post(
      Uri.parse("${AppConstants.baseUrl}/orders/place_order.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"items": items}),
    );

    return jsonDecode(res.body);
  }
}
