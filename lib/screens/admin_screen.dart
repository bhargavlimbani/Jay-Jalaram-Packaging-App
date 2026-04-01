// import 'dart:convert';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:jay_jalaram_packaging/admin_information/customer_detail_screen.dart';
import '../services/api_service.dart';
import '../admin_information/add_product.dart';
import '../admin_information/edit_product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminScreen extends StatefulWidget {
  final int? adminId;

  AdminScreen({this.adminId});
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int selectedIndex = -1; // 🔥 dashboard first

  List orders = [];
  List customers = [];
  List products = [];

  String message = "";

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  int adminId = 1;

  @override
  void initState() {
    super.initState();
    fetchOrders();
    fetchProducts();
    fetchCustomers();
    fetchProfile();
  }

  void fetchOrders() async {
    var data = await ApiService.getallOrders(widget.adminId ?? 1);
    setState(() => orders = data);
  }

  void fetchProducts() async {
    var data = await ApiService.getProducts();
    setState(() => products = data);
  }

  void fetchCustomers() async {
    var data = await ApiService.getCustomers();
    setState(() => customers = data);
  }

  void fetchProfile() async {
    var res = await ApiService.getProfile(widget.adminId ?? 1);

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
      "user_id": widget.adminId,
      "name": nameController.text,
      "email": emailController.text,
      "phone": phoneController.text,
      "address": addressController.text,
    });

    fetchProfile();

    setState(() {
      message = res["message"];
    });
  }

  void updateStatus(int id, String status) async {
    await ApiService.updateOrderStatus(id, status);
    fetchOrders();
  }

  void deleteProduct(int id) async {
    await ApiService.deleteProduct(id);
    fetchProducts();
  }

  // 🔥 DASHBOARD GRID
  Widget dashboardGrid() {
    List<Map<String, dynamic>> items = [
      {
        "icon": Icons.people,
        "title": "Customers",
        "index": 0,
        "count": customers.length,
      },
      {
        "icon": Icons.list,
        "title": "Orders",
        "index": 1,
        "count": orders.length,
      },
      {
        "icon": Icons.inventory,
        "title": "Products",
        "index": 2,
        "count": products.length,
      },
      {"icon": Icons.receipt, "title": "Invoice", "index": 3, "count": 0},
      {"icon": Icons.person, "title": "Profile", "index": 4, "count": 0},
    ];

    return Padding(
      padding: EdgeInsets.all(16),
      child: GridView.builder(
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, i) {
          var item = items[i];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = item["index"];
              });
            },

            // 🔥 ANIMATION
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, blurRadius: 5),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ICON
                  Icon(item["icon"], size: 30, color: Colors.teal),

                  SizedBox(height: 8),

                  // TITLE
                  Text(
                    item["title"],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 5),

                  // 🔥 COUNT
                  if (item["count"] > 0)
                    Text(
                      "(${item["count"]})",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget ordersPage() {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, i) {
        var o = orders[i];

        return Card(
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order #${o["id"]}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Customer: ${o["customer_name"]}"),
                Text("Total: ₹${o["total_price"]}"),
                Text("Status: ${o["status"]}"),
                SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => updateStatus(o["id"], "Accepted"),
                      child: Text("Accept"),
                    ),
                    SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () => updateStatus(o["id"], "Rejected"),
                      child: Text("Reject"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget customersPage() {
    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, i) {
        var c = customers[i];
        return ListTile(
          title: Text(c["name"]),
          subtitle: Text(c["email"]),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CustomerDetailScreen(id: int.parse(c["id"].toString())),
              ),
            );
          },
        );
      },
    );
  }

  Widget productsPage() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddProductScreen()),
            ).then((_) {
              fetchProducts();
            });
          },
          child: Text("Add Product"),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, i) {
              var p = products[i];

              Uint8List? imageBytes;
              try {
                if (p["image_data"] != null && p["image_data"] != "") {
                  String base64String = p["image_data"];
                  base64String = base64String
                      .replaceAll("data:image/jpeg;base64,", "")
                      .replaceAll("data:image/png;base64,", "");
                  imageBytes = base64Decode(base64String);
                }
              } catch (e) {}

              return Card(
                child: ListTile(
                  leading: imageBytes != null
                      ? Image.memory(imageBytes, width: 50, height: 50)
                      : Icon(Icons.image),
                  title: Text(p["name"]),
                  subtitle: Text("₹${p["price"]}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditProductScreen(product: p),
                            ),
                          ).then((_) => fetchProducts());
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          int id = int.tryParse(p["id"].toString()) ?? 0;
                          deleteProduct(id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget invoicePage() {
    return Center(child: Text("Invoice Coming Soon"));
  }

  Widget profilePage() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          if (message.isNotEmpty)
            Container(
              padding: EdgeInsets.all(10),
              color: Colors.green[200],
              child: Text(message),
            ),
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: "Name"),
          ),
          TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: "Email"),
          ),
          TextField(
            controller: phoneController,
            decoration: InputDecoration(labelText: "Phone"),
          ),
          TextField(
            controller: addressController,
            decoration: InputDecoration(labelText: "Address"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: updateProfile,
            child: Text("Update Profile"),
          ),
          ElevatedButton(onPressed: _logout, child: Text("Logout")),
        ],
      ),
    );
  }

  Widget getPage() {
    if (selectedIndex == -1) return dashboardGrid();

    switch (selectedIndex) {
      case 0:
        return customersPage();
      case 1:
        return ordersPage();
      case 2:
        return productsPage();
      case 3:
        return invoicePage();
      case 4:
        return profilePage();
      default:
        return dashboardGrid();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Panel"),
        backgroundColor: Colors.teal,

        // 🔙 BACK BUTTON
        leading: selectedIndex != -1
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    selectedIndex = -1;
                  });
                },
              )
            : null,

        // 🏠 HOME BUTTON
        actions: [
          if (selectedIndex != -1)
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                setState(() {
                  selectedIndex = -1;
                });
              },
            ),
        ],
      ),

      body: getPage(),

      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: selectedIndex < 0 ? 0 : selectedIndex,
      //   onTap: (index) {
      //     setState(() {
      //       selectedIndex = index;
      //     });
      //   },
      //   selectedItemColor: Colors.teal,
      //   type: BottomNavigationBarType.fixed,
      //   items: [
      //     BottomNavigationBarItem(icon: Icon(Icons.people), label: "Customers"),
      //     BottomNavigationBarItem(icon: Icon(Icons.list), label: "Orders"),
      //     BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Products"),
      //     BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Invoice"),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      //   ],
      // ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, "/login");
  }
}
