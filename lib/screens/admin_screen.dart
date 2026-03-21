import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int selectedIndex = 0;

  List orders = [];
  List customers = [];
  List products = [];

  String message = "";

  @override
  void initState() {
    super.initState();
    fetchOrders();
    fetchProducts();
    fetchCustomers();
  }

  // ================= API =================

  void fetchOrders() async {
    var data = await ApiService.getOrders();
    setState(() => orders = data);
  }

  void fetchProducts() async {
    var data = await ApiService.getProducts();
    setState(() => products = data);
  }

  void fetchCustomers() async {
    var data = await ApiService.getCustomers(); // create API
    setState(() => customers = data);
  }

  void updateStatus(int id, String status) async {
    await ApiService.updateOrderStatus(id, status);
    fetchOrders();
  }

  void deleteProduct(int id) async {
    await ApiService.deleteProduct(id);
    fetchProducts();
  }

  // ================= UI PAGES =================

  // 📦 ORDERS
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

  // 👥 CUSTOMERS
  Widget customersPage() {
    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, i) {
        var c = customers[i];

        return ListTile(title: Text(c["name"]), subtitle: Text(c["email"]));
      },
    );
  }

  // 🛒 PRODUCTS
  Widget productsPage() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, "/addProduct");
          },
          child: Text("Add Product"),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, i) {
              var p = products[i];

              return Card(
                child: ListTile(
                  title: Text(p["name"]),
                  subtitle: Text("₹${p["price"]}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            "/editProduct",
                            arguments: p,
                          );
                        },
                      ),

                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteProduct(p["id"]),
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

  // 🧾 INVOICE
  Widget invoicePage() {
    return Center(child: Text("Invoice Coming Soon"));
  }

  // 👤 PROFILE
  Widget profilePage() {
    return Column(
      children: [
        TextField(decoration: InputDecoration(labelText: "Name")),
        TextField(decoration: InputDecoration(labelText: "Email")),

        ElevatedButton(onPressed: () {}, child: Text("Update Profile")),

        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/login");
          },
          child: Text("Logout"),
        ),
      ],
    );
  }

  // ================= PAGE SWITCH =================

  Widget getPage() {
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
        return ordersPage();
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Panel"), backgroundColor: Colors.teal),

      body: getPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        backgroundColor: Colors.white, // 🔥 important

        selectedItemColor: Colors.teal, // active color
        unselectedItemColor: Colors.grey, // inactive color

        showUnselectedLabels: true, // 🔥 show all labels

        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Customers"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Orders"),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: "Products",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Invoice"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
