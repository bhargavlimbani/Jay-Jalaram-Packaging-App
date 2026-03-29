import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'admin_information/add_product.dart';
import 'screens/admin_screen.dart';
import 'screens/customer_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<Widget> _getStartScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");
    final role = prefs.getString("role");

    if (userId != null && role != null) {
      if (role == "admin") {
        return AdminScreen(adminId: userId);
      }
      return CustomerScreen(userId: userId);
    }

    return LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getStartScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: snapshot.data ?? LoginScreen(),
          routes: {
            "/login": (context) => LoginScreen(),
            "/register": (context) => RegisterScreen(),
            "/forgot": (context) => ForgotPasswordScreen(),
            "/add_product": (context) => AddProductScreen(),
          },
        );
      },
    );
  }
}
