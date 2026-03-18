import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController otp = TextEditingController();
  TextEditingController password = TextEditingController();

  bool otpSent = false;
  String message = "";
  String error = "";
  bool loading = false;

  void sendOtp() async {
    setState(() => loading = true);

    var res = await ApiService.forgotPassword(email.text);

    setState(() {
      otpSent = true;
      message = res["message"];
      loading = false;
    });
  }

  void resetPassword() async {
    setState(() => loading = true);

    var res = await ApiService.resetPassword(
      email.text,
      otp.text,
      password.text,
    );

    setState(() {
      message = res["message"];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(labelText: "Email"),
            ),

            if (otpSent) ...[
              TextField(
                controller: otp,
                decoration: InputDecoration(labelText: "OTP"),
              ),
              TextField(
                controller: password,
                decoration: InputDecoration(labelText: "New Password"),
              ),
            ],

            if (error.isNotEmpty)
              Text(error, style: TextStyle(color: Colors.red)),

            if (message.isNotEmpty)
              Text(message, style: TextStyle(color: Colors.green)),

            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/login");
              },
              child: Text("Back to Login"),
            ),
            ElevatedButton(
              onPressed: loading ? null : (otpSent ? resetPassword : sendOtp),
              child: Text(otpSent ? "Reset Password" : "Send OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
