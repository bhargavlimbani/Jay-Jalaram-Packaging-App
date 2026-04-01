// import 'dart:convert';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:jay_jalaram_packaging/admin_information/customer_detail_screen.dart';
import '../services/api_service.dart';
import '../admin_information/add_product.dart';
import '../admin_information/edit_product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:printing/printing.dart';
import '../admin_information/invoice_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

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
  List invoices = [];

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
    fetchInvoices();
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

  void fetchInvoices() async {
    var data = await ApiService.getInvoices();
    setState(() => invoices = data ?? []);
  }

  String _pickValue(Map data, List<String> keys) {
    for (final k in keys) {
      if (data.containsKey(k) && data[k] != null && data[k].toString() != "") {
        return data[k].toString();
      }
    }
    return "";
  }

  String _pickInvoiceUrl(Map data) {
    return _pickValue(data, ["pdf_url", "invoice_url", "file_url", "url"]);
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot open invoice link")),
      );
    }
  }

  void _showInvoiceActions(Map invoice) {
    final url = _pickInvoiceUrl(invoice);

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No invoice file found")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.visibility),
                title: Text("View"),
                onTap: () {
                  Navigator.pop(context);
                  _openUrl(url);
                },
              ),
              ListTile(
                leading: Icon(Icons.download),
                title: Text("Download"),
                onTap: () {
                  Navigator.pop(context);
                  _openUrl(url);
                },
              ),
              ListTile(
                leading: Icon(Icons.share),
                title: Text("Share"),
                onTap: () {
                  Navigator.pop(context);
                  Share.share(url);
                },
              ),
            ],
          ),
        );
      },
    );
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

  void updateStatus(int id, String status, Map order) async {
    print("CALL API: ID=$id STATUS=$status");

    var res = await ApiService.updateOrderStatus(id, status);

    print("API RESPONSE: $res");

    if (res["status"] == "success") {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res["message"])));

      fetchOrders();

      // 🔥 AUTO INVOICE WHEN COMPLETED
      if (status == "Completed") {
        generateInvoiceAndShare(order);
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res["message"])));
    }
  }

  void deleteProduct(int id) async {
    await ApiService.deleteProduct(id);
    fetchProducts();
  }


void generateInvoiceAndShare(Map order) async {
  final pdfData = await InvoiceService.generateInvoice(order);

  await Printing.layoutPdf(
    onLayout: (format) async => pdfData,
  );
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
      {
        "icon": Icons.receipt,
        "title": "Invoice",
        "index": 3,
        "count": invoices.length,
      },
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
                      onPressed: () => updateStatus(
                        int.parse(o["id"].toString()),
                        "Accepted",
                        o,
                      ),
                      child: Text("Accept"),
                    ),

                    ElevatedButton(
                      onPressed: () => updateStatus(
                        int.parse(o["id"].toString()),
                        "Rejected",
                        o,
                      ),
                      child: Text("Reject"),
                    ),

                    ElevatedButton(
                      onPressed: () => updateStatus(
                        int.parse(o["id"].toString()),
                        "Completed",
                        o,
                      ),
                      child: Text("Complete"),
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
    if (invoices.isEmpty) {
      return Center(child: Text("No invoices yet"));
    }

    return ListView.separated(
      padding: EdgeInsets.all(12),
      itemCount: invoices.length,
      separatorBuilder: (_, __) => SizedBox(height: 8),
      itemBuilder: (context, i) {
        final inv = invoices[i] as Map;

        final id = _pickValue(inv, ["id", "invoice_id"]);
        final userId = _pickValue(inv, ["user_id", "customer_id"]);
        final total = _pickValue(inv, ["total", "total_price", "amount"]);
        final date = _pickValue(inv, ["created_at", "date", "invoice_date"]);
        final status = _pickValue(inv, ["status", "payment_status"]);

        return Card(
          elevation: 1.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showInvoiceActions(inv),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    id.isNotEmpty ? "Invoice #$id" : "Invoice",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (userId.isNotEmpty) Text("User ID: $userId"),
                  if (total.isNotEmpty) Text("Total: ₹$total"),
                  if (date.isNotEmpty) Text("Date: $date"),
                  if (status.isNotEmpty)
                    Text(
                      "Status: $status",
                      style: TextStyle(color: Colors.teal),
                    ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.more_horiz, size: 18, color: Colors.grey),
                      SizedBox(width: 6),
                      Text(
                        "Tap for options",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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
