import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController otp = TextEditingController();

  bool otpSent = false;
  String message = "";
  String error = "";
  bool loading = false;
  void sendOtp() async {
    setState(() {
      error = "";
      message = "";
    });

    var res = await ApiService.register(
      name.text,
      email.text,
      phone.text,
      address.text,
      password.text,
    );

    print("FULL RESPONSE: $res"); // 🔥 check in console
    print("OTP: ${res["otp"]}"); // 🔥 THIS IS IMPORTANT

    setState(() {
      otpSent = true;
      message = "OTP: ${res["otp"]}"; // 👈 show on screen
    });
  }

  void verifyOtp() async {
    setState(() => loading = true);

    var res = await ApiService.verifyOtp(email.text, otp.text);

    if (res["status"] == "success") {
      Navigator.pop(context);
    } else {
      setState(() => error = res["message"]);
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: email,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: phone,
              decoration: InputDecoration(labelText: "Phone"),
            ),
            TextField(
              controller: password,
              decoration: InputDecoration(labelText: "Password"),
            ),
            TextField(
              controller: address,
              decoration: InputDecoration(labelText: "Address"),
            ),

            if (otpSent)
              TextField(
                controller: otp,
                decoration: InputDecoration(labelText: "Enter OTP"),
              ),

            if (error.isNotEmpty)
              Text(error, style: TextStyle(color: Colors.red)),

            if (message.isNotEmpty)
              Text(message, style: TextStyle(color: Colors.green)),

            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/login");
              },
              child: Text("Already have account? Login"),
            ),
            ElevatedButton(
              onPressed: loading ? null : (otpSent ? verifyOtp : sendOtp),
              child: Text(otpSent ? "Verify OTP" : "Send OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
