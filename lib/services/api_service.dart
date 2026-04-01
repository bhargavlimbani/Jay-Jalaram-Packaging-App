import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static Future getProfile(int userId) async {
    var response = await http.get(
      Uri.parse("${AppConstants.baseUrl}/auth/profile.php?user_id=$userId"),
    );

    return jsonDecode(response.body);
  }

  // ================= PROFILE UPDATE =================
  static Future updateProfile(Map data) async {
    var response = await http.post(
      Uri.parse("${AppConstants.baseUrl}/auth/profile.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }

  static Future getCustomerById(int id) async {
    var res = await http.get(
      Uri.parse("${AppConstants.baseUrl}/admin/get_customer_by_id.php?id=$id"),
    );

    return jsonDecode(res.body);
  }

  static Future updateCustomer(Map data) async {
    var res = await http.post(
      Uri.parse("${AppConstants.baseUrl}/admin/update_customer.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return jsonDecode(res.body);
  }

  static Future<List> getProducts() async {
    var res = await http.get(
      Uri.parse("${AppConstants.baseUrl}/products/get_products.php"),
    );
    return jsonDecode(res.body);
  }

  static Future addProduct({
    required String name,
    required String price,
    required String boxType,
    required String imagePath,
    required String description,
    required String stock,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${AppConstants.baseUrl}/products/add_product.php"),
    );

    request.fields['name'] = name;
    request.fields['price'] = price;
    request.fields['box_type'] = boxType;
    request.fields['description'] = description;
    request.fields['stock'] = stock;

    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    var response = await request.send();
    var res = await http.Response.fromStream(response);

    return jsonDecode(res.body);
  }

  static Future deleteProduct(int id) async {
    var res = await http.post(
      Uri.parse("${AppConstants.baseUrl}/products/delete_product.php"),
      body: {"id": id.toString()},
    );

    return jsonDecode(res.body);
  }

  static Future updateProduct({
    required String id,
    required String name,
    required String price,
    required String boxType,
    required String description,
    required String stock,
    String? imagePath,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${AppConstants.baseUrl}/products/update_product.php"),
    );

    request.fields['id'] = id;
    request.fields['name'] = name;
    request.fields['price'] = price;
    request.fields['box_type'] = boxType;
    request.fields['description'] = description;
    request.fields['stock'] = stock;

    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    var response = await request.send();
    var res = await http.Response.fromStream(response);

    return jsonDecode(res.body);
  }

  static Future<List> getallOrders(int userId) async {
    var res = await http.get(
      Uri.parse("${AppConstants.baseUrl}/orders/get_my_orders.php"),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateOrderStatus(
    int orderId,
    String status,
  ) async {
    var res = await http.post(
      Uri.parse("${AppConstants.baseUrl}/orders/update_order_status.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"order_id": orderId, "status": status}),
    );
    return jsonDecode(res.body);
  }

  static Future<List> getCustomers() async {
    var res = await http.get(
      Uri.parse("${AppConstants.baseUrl}/auth/get_customers.php"),
    );
    return jsonDecode(res.body);
  }

static Future getorders(int userId) async {
  var res = await http.post(
    Uri.parse("${AppConstants.baseUrl}/orders/get_orders.php"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"user_id": userId}),
  );

  return jsonDecode(res.body);
}

static Future placeOrder(Map data) async {
  var res = await http.post(
    Uri.parse("${AppConstants.baseUrl}/orders/place_order.php"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data),
  );

  return jsonDecode(res.body);
}
static Future cancelOrder(int id) async {
  print("Sending order_id: $id"); 

  var res = await http.post(
    Uri.parse("${AppConstants.baseUrl}/orders/cancel_order.php"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"order_id": id}),
  );

  print("Response: ${res.body}"); 

  return jsonDecode(res.body);
}
}
