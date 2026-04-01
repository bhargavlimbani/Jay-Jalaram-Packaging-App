import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerScreen extends StatefulWidget {
  final int userId;

  CustomerScreen({required this.userId});

  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  int selectedIndex = 0;

  List products = [];
  List orders = [];
  List cartItems = [];

  Map<int, TextEditingController> qtyControllers = {};

  String message = "";
  String search = "";
  String selectedCategory = "";

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchOrders();
    fetchProfile();
  }

  void fetchProducts() async {
    var data = await ApiService.getProducts();
    setState(() => products = data);
  }

void fetchOrders() async {
  var data = await ApiService.getorders(widget.userId); // 🔥 IMPORTANT
  setState(() => orders = data);
}

  void fetchProfile() async {
    var res = await ApiService.getProfile(widget.userId);

    if (res["status"] == "success") {
      var p = res["profile"];

      setState(() {
        nameController.text = p["name"] ?? "";
        emailController.text = p["email"] ?? "";
        phoneController.text = p["phone"] ?? "";
        addressController.text = p["address"] ?? "";
      });
    }
  }

  void updateProfile() async {
    var res = await ApiService.updateProfile({
      "user_id": widget.userId,
      "name": nameController.text,
      "email": emailController.text,
      "phone": phoneController.text,
      "address": addressController.text,
    });

    setState(() => message = res["message"]);
  }

  // ✅ FIXED IMAGE FUNCTION
  Widget showImage(String? base64) {
    try {
      if (base64 == null || base64.isEmpty) {
        return Icon(Icons.image);
      }

      String data = base64.split(',').last;
      Uint8List bytes = base64Decode(data);

      return Image.memory(bytes, fit: BoxFit.cover);
    } catch (e) {
      return Icon(Icons.image);
    }
  }

  void addToCart(product, int qty) {
    setState(() {
      cartItems.add({
        "product_id": product["id"],
        "name": product["name"],
        "price": double.parse(product["price"].toString()),
        "qty": qty,
        "image_data": product["image_data"],
      });
    });
  }

  void placeOrder() async {
    if (cartItems.isEmpty) return;

    var res = await ApiService.placeOrder({
      "user_id": widget.userId,
      "items": cartItems,
    });

    setState(() {
      cartItems.clear();
      message = res["message"];
      selectedIndex = 1;
    });

    fetchOrders();
  }

  void cancelOrder(int orderId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to cancel this order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              var res = await ApiService.cancelOrder(orderId);

              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(res["message"])));

              fetchOrders();
            },
            child: Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ================= HOME =================
  Widget homePage() {
    var filtered = products.where((p) {
      return (p["name"] ?? "").toLowerCase().contains(search.toLowerCase());
    }).toList();

    return Column(
      children: [
        if (message.isNotEmpty)
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.green[200],
            child: Text(message),
          ),

        Padding(
          padding: EdgeInsets.all(10),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => setState(() => search = val),
          ),
        ),

        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              var p = filtered[i];
              int id = int.tryParse(p["id"]?.toString() ?? "0") ?? 0;

              qtyControllers.putIfAbsent(
                  id, () => TextEditingController(text: "1"));

              return Card(
                child: Column(
                  children: [
                    Expanded(
                      child: showImage(p["image_data"]?.toString()),
                    ),

                    Text(p["name"]?.toString() ?? ""),
                    Text("₹${p["price"]?.toString() ?? "0"}"),

                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            int qty =
                                int.tryParse(qtyControllers[id]!.text) ?? 1;
                            if (qty > 1) qty--;
                            setState(() {
                              qtyControllers[id]!.text = qty.toString();
                            });
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: qtyControllers[id],
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            int qty =
                                int.tryParse(qtyControllers[id]!.text) ?? 1;
                            qty++;
                            setState(() {
                              qtyControllers[id]!.text = qty.toString();
                            });
                          },
                        ),
                      ],
                    ),

                    ElevatedButton(
                      onPressed: () {
                        int qty =
                            int.tryParse(qtyControllers[id]!.text) ?? 1;
                        addToCart(p, qty);
                      },
                      child: Text("Order Box"),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ================= CART =================
  Widget cartPage() {
    double total = 0;

    for (var item in cartItems) {
      total += (item["price"] ?? 0) * (item["qty"] ?? 0);
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, i) {
              var item = cartItems[i];

              return Dismissible(
                key: Key(item["product_id"].toString()),
                background: Container(color: Colors.red),
                onDismissed: (_) {
                  setState(() => cartItems.removeAt(i));
                },
                child: Card(
                  child: ListTile(
                    leading: SizedBox(
                      width: 60,
                      height: 60,
                      child: showImage(item["image_data"]?.toString()),
                    ),
                    title: Text(item["name"]?.toString() ?? ""),
                    subtitle: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if ((item["qty"] ?? 1) > 1) item["qty"]--;
                            });
                          },
                        ),
                        Text("${item["qty"] ?? 0}"),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() => item["qty"]++);
                          },
                        ),
                      ],
                    ),
                    trailing: Text(
                        "₹${(item["price"] ?? 0) * (item["qty"] ?? 0)}"),
                  ),
                ),
              );
            },
          ),
        ),

        Text("Total: ₹$total"),

        ElevatedButton(
          onPressed: cartItems.isEmpty ? null : placeOrder,
          child: Text("Place Order"),
        ),
      ],
    );
  }

  // ================= ORDERS =================
  Widget ordersPage() {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, i) {
        var order = orders[i];

        List items = [];
        try {
          items = jsonDecode(order["items"] ?? "[]");
        } catch (e) {}

        return Card(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Order ID: ${order["id"]?.toString() ?? ""}"),
                Text("Total: ₹${order["total_price"]?.toString() ?? "0"}"),

                Text(
                  "Status: ${order["status"]?.toString() ?? ""}",
                  style: TextStyle(color: Colors.orange),
                ),

                if (order["status"] == "Pending")
                  ElevatedButton(
                    onPressed: () {
                      cancelOrder(
                          int.tryParse(order["id"]?.toString() ?? "0") ?? 0);
                    },
                    child: Text("Cancel Order"),
                  ),

                SizedBox(height: 10),

                ...items.map((item) {
                  return Row(
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: showImage(item["image"]?.toString()),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item["name"]?.toString() ?? ""),
                          Text("Qty: ${item["quantity"] ?? 0}"),
                        ],
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= PROFILE =================
  Widget profilePage() {
    InputDecoration fieldStyle(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal, width: 1.5),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (message.isNotEmpty)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                message,
                style: TextStyle(color: Colors.green.shade900),
              ),
            ),
          SizedBox(height: 16),
          Text(
            "My Profile",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          TextField(
            controller: nameController,
            decoration: fieldStyle("Name", Icons.person),
          ),
          SizedBox(height: 12),
          TextField(
            controller: emailController,
            decoration: fieldStyle("Email", Icons.email),
          ),
          SizedBox(height: 12),
          TextField(
            controller: phoneController,
            decoration: fieldStyle("Phone", Icons.phone),
          ),
          SizedBox(height: 12),
          TextField(
            controller: addressController,
            decoration: fieldStyle("Address", Icons.location_on),
            maxLines: 2,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: updateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text("Update Profile"),
          ),
          SizedBox(height: 10),
          OutlinedButton(
            onPressed: _logout,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade300),
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }

  Widget getPage() {
    switch (selectedIndex) {
      case 0:
        return homePage();
      case 1:
        return ordersPage();
      case 2:
        return cartPage();
      case 3:
        return profilePage();
      default:
        return homePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello Customer"),
        backgroundColor: Colors.teal,
      ),
      body: getPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) => setState(() => selectedIndex = i),
        backgroundColor: Colors.white,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Orders"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, "/login");
  }
}
