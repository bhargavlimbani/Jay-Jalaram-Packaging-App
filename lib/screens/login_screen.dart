import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'customer_screen.dart';
import 'admin_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isPasswordHidden = true;
  String errorMessage = "";

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text;

    setState(() => errorMessage = "");

    if (email.isEmpty || !email.contains("@")) {
      setState(() {
        errorMessage = "Enter valid email";
      });
      return;
    }

    var data = await ApiService.login(email, password);

    if (data["status"] == "success") {
      var user = data["user"];

      if (user["role"] == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CustomerScreen()),
        );
      }
    } else {
      setState(() {
        errorMessage = data["message"];
      });
    }
  }

  Widget customInput({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.teal),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? isPasswordHidden : false,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.teal),
          hintText: hint,
          border: InputBorder.none,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordHidden
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.teal,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordHidden = !isPasswordHidden;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // 🔥 LOGO
                Image.asset("assets/logo.png", height: 100),

                SizedBox(height: 20),

                // EMAIL
                customInput(
                  hint: "Email",
                  icon: Icons.email,
                  controller: emailController,
                ),

                // PASSWORD
                customInput(
                  hint: "Password",
                  icon: Icons.lock,
                  controller: passwordController,
                  isPassword: true,
                ),

                SizedBox(height: 20),

                // LOGIN BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: login,
                  child: Text("Login", style: TextStyle(fontSize: 16)),
                ),

                SizedBox(height: 10),

                // ERROR
                if (errorMessage.isNotEmpty)
                  Text(errorMessage,
                      style: TextStyle(color: Colors.red)),

                SizedBox(height: 10),

                // FORGOT
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/forgot");
                  },
                  child: Text("Forgot Password"),
                ),

                // REGISTER
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/register");
                  },
                  child: Text("Don't have an account? Register"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}