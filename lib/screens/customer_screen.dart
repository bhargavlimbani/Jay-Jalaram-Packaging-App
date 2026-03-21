import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CustomerScreen extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchOrders();
  }

  // ================= FETCH =================
  void fetchProducts() async {
    var data = await ApiService.getProducts();
    setState(() {
      products = data;
    });
  }

  void fetchOrders() async {
    var data = await ApiService.getOrders();
    setState(() {
      orders = data;
    });
  }

  // ================= IMAGE =================
  Widget showImage(String base64String) {
    try {
      String base64Data = base64String.split(',').last;
      Uint8List bytes = base64Decode(base64Data);

      return Image.memory(
        bytes,
        height: 100,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } catch (e) {
      return Icon(Icons.image_not_supported, size: 80);
    }
  }

  // ================= CART =================
  void addToCart(product, int qty) {
    int productId = int.parse(product["id"].toString());

    setState(() {
      cartItems.add({
        "product_id": productId,
        "name": product["name"],
        "price": double.parse(product["price"].toString()),
        "qty": qty
      });

      message = "${product["name"]} added to cart";
    });
  }

  void placeOrder() async {
    var res = await ApiService.placeOrder(cartItems);

    print("ORDER RESPONSE: $res");

    setState(() {
      cartItems.clear();
      message = res["message"] ?? "Order placed";
      selectedIndex = 1;
    });

    fetchOrders();
  }

  // ================= HOME =================
  Widget homePage() {
    return Column(
      children: [
        if (message.isNotEmpty)
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            color: Colors.green[200],
            child: Text(message),
          ),

        Padding(
          padding: EdgeInsets.all(10),
          child: Text("Products",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),

        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.55, // 🔥 FIX OVERFLOW
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index];
              int productId = int.parse(product["id"].toString());

              qtyControllers.putIfAbsent(
                  productId, () => TextEditingController(text: "1"));

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 3,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: SingleChildScrollView( // 🔥 FIX OVERFLOW
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // IMAGE
                        product["image_data"] != null &&
                                product["image_data"] != ""
                            ? showImage(product["image_data"])
                            : Icon(Icons.image, size: 80),

                        SizedBox(height: 5),

                        Text(product["name"],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),

                        Text("₹${product["price"]}"),
                        Text("Stock: ${product["stock"]}"),

                        SizedBox(height: 5),

                        TextField(
                          controller: qtyControllers[productId],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Qty",
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),

                        SizedBox(height: 5),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            minimumSize: Size(double.infinity, 40),
                          ),
                          onPressed: () {
                            int qty = int.tryParse(
                                    qtyControllers[productId]!.text) ??
                                1;

                            addToCart(product, qty);
                          },
                          child: Text("Add"),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  // ================= CART =================
  Widget cartPage() {
    double total = 0;

    for (var item in cartItems) {
      total += item["price"] * item["qty"];
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              var item = cartItems[index];

              return ListTile(
                title: Text(item["name"]),
                subtitle: Text("Qty: ${item["qty"]}"),
                trailing: Text("₹${item["price"] * item["qty"]}"),
              );
            },
          ),
        ),

        Padding(
          padding: EdgeInsets.all(10),
          child: Text("Total: ₹$total",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),

        ElevatedButton(
          onPressed: cartItems.isEmpty ? null : placeOrder,
          child: Text("Place Order"),
        )
      ],
    );
  }

  // ================= ORDERS =================
  Widget ordersPage() {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        var order = orders[index];

        return Card(
          child: ListTile(
            title: Text("Order ID: ${order["id"]}"),
            subtitle: Text("₹${order["total_price"]}"),
          ),
        );
      },
    );
  }

  // ================= PROFILE =================
  Widget profilePage() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(decoration: InputDecoration(labelText: "Name")),
          TextField(decoration: InputDecoration(labelText: "Phone")),
          TextField(decoration: InputDecoration(labelText: "Address")),

          SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              setState(() {
                message = "Profile updated";
              });
            },
            child: Text("Update Profile"),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, "/login");
            },
            child: Text("Logout"),
          )
        ],
      ),
    );
  }

  // ================= NAV =================
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
        selectedItemColor: Colors.teal,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Orders"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}