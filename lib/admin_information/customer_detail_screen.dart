import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
// import 'package:country_codes/country_codes.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int id;

  CustomerDetailScreen({required this.id});

  @override
  _CustomerDetailScreenState createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  Map? customer;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    fetchCustomer();
  }

  void fetchCustomer() async {
    var res = await ApiService.getCustomerById(widget.id);

    if (res["status"] == "success") {
      var c = res["customer"];

      setState(() {
        customer = c;

        nameController.text = c["name"] ?? "";
        emailController.text = c["email"] ?? "";
        phoneController.text = c["phone"] ?? "";
        addressController.text = c["address"] ?? "";
      });
    }
  }

  // 📞 CALL
  void callCustomer() async {
    final Uri url = Uri.parse("tel:${phoneController.text}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

// void openWhatsAppWithOrder({
//   required String customerName,
//   required String productName,
//   required String price,
//   required String quantity,
// }) async {

//   String phone = phoneController.text;

//   // clean number
//   phone = phone.replaceAll(RegExp(r'[^0-9]'), '');

//   // auto country detect
//   String countryCode = window.locale.countryCode ?? "IN";

//   String dialCode = "91";
//   if (countryCode == "US") dialCode = "1";
//   if (countryCode == "UK") dialCode = "44";

//   if (phone.length <= 10) {
//     phone = dialCode + phone;
//   }

//   // 🧾 MESSAGE
//   String message = """
// Hello $customerName,

// Your order details:

// 📦 Product: $productName
// 💰 Price: ₹$price
// 🔢 Quantity: $quantity

// Thank you for your order!
// """;

//   // encode message
//   String encodedMessage = Uri.encodeComponent(message);

//   try {
//     final Uri appUrl = Uri.parse(
//       "whatsapp://send?phone=$phone&text=$encodedMessage",
//     );

//     await launchUrl(appUrl, mode: LaunchMode.externalApplication);
//   } catch (e) {
//     final Uri webUrl = Uri.parse(
//       "https://wa.me/$phone?text=$encodedMessage",
//     );

//     await launchUrl(webUrl, mode: LaunchMode.externalApplication);
//   }
// }

  // 💬 WHATSAPP
  void openWhatsApp() async {
    String phone = phoneController.text;

    // clean number
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // 🔥 AUTO DETECT COUNTRY FROM DEVICE LOCALE
    String countryCode = window.locale.countryCode ?? "IN";

    String dialCode = "91"; // default India

    // basic mapping (add more if needed)
    if (countryCode == "US") dialCode = "1";
    if (countryCode == "IN") dialCode = "91";
    if (countryCode == "UK") dialCode = "44";

    // if not already full number
    if (phone.length <= 10) {
      phone = dialCode + phone;
    }

    try {
      final Uri appUrl = Uri.parse("whatsapp://send?phone=$phone");
      await launchUrl(appUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      final Uri webUrl = Uri.parse("https://wa.me/$phone");
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  // 📋 COPY FUNCTION
  void copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Copied")));
  }

  @override
  Widget build(BuildContext context) {
    if (customer == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Customer Detail"),
          backgroundColor: Colors.teal,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Customer Detail"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(isEdit ? Icons.save : Icons.edit),
            onPressed: () async {
              if (isEdit) {
                // 🔥 SAVE TO DB
                var res = await ApiService.updateCustomer({
                  "id": widget.id,
                  "name": nameController.text,
                  "email": emailController.text,
                  "phone": phoneController.text,
                  "address": addressController.text,
                });

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(res["message"])));

                if (res["status"] == "success") {
                  setState(() => isEdit = false);
                }
              } else {
                setState(() => isEdit = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            buildField("Name", nameController),
            SizedBox(height: 10),

            buildField(
              "Email",
              emailController,
              copy: true,
              value: emailController.text,
            ),
            SizedBox(height: 10),

            buildField(
              "Phone",
              phoneController,
              call: true,
              copy: true,
              value: phoneController.text,
            ),
            SizedBox(height: 10),

            buildField("Address", addressController),
          ],
        ),
      ),
    );
  }

  // 🔥 FIELD UI
  Widget buildField(
    String label,
    TextEditingController controller, {
    bool call = false,
    bool copy = false,
    String value = "",
  }) {
    return TextField(
      controller: controller,
      readOnly: !isEdit,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (call)
              IconButton(
                icon: Icon(Icons.call, color: Colors.green),
                onPressed: callCustomer,
              ),
            // whatsapp
            if (call)
              IconButton(
                icon: Icon(Icons.chat, color: Colors.teal),
                onPressed: openWhatsApp,
              ),

            if (copy)
              IconButton(
                icon: Icon(Icons.copy),
                onPressed: () => copyText(value),
              ),
          ],
        ),
      ),
    );
  }
}
