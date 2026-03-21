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
  String search = "";
  String selectedCategory = "";

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchOrders();
  }

  // ================= FETCH =================
  void fetchProducts() async {
    var data = await ApiService.getProducts();
    setState(() => products = data);
  }

  void fetchOrders() async {
    var data = await ApiService.getOrders();
    setState(() => orders = data);
  }

  // ================= IMAGE =================
  Widget showImage(String base64String) {
    try {
      String base64Data = base64String.split(',').last;
      Uint8List bytes = base64Decode(base64Data);

      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } catch (e) {
      return Icon(Icons.image_not_supported, size: 80);
    }
  }

  // ================= CART =================
  void addToCart(product, int qty) {
    setState(() {
      cartItems.add({
        "product_id": product["id"],
        "name": product["name"],
        "price": double.parse(product["price"].toString()),
        "qty": qty,
      });

      message = "${product["name"]} added";
    });
  }

  void placeOrder() async {
    var res = await ApiService.placeOrder(cartItems);

    setState(() {
      cartItems.clear();
      message = res["message"];
      selectedIndex = 1;
    });

    fetchOrders();
  }

  // ================= CATEGORY BUTTON =================
  Widget categoryButton(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selectedCategory == value ? Colors.teal : Colors.grey[300],
        ),
        onPressed: () {
          setState(() {
            selectedCategory = value;
          });
        },
        child: Text(title),
      ),
    );
  }

  // ================= HOME =================
  Widget homePage() {
    var filteredProducts = products.where((p) {
      bool matchSearch =
          p["name"].toLowerCase().contains(search.toLowerCase());

      bool matchCategory =
          selectedCategory == "" || p["box_type"] == selectedCategory;

      return matchSearch && matchCategory;
    }).toList();

    return Column(
      children: [

        // MESSAGE
        if (message.isNotEmpty)
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            color: Colors.green[200],
            child: Text(message),
          ),

        // SEARCH
        Padding(
          padding: EdgeInsets.all(10),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search boxes...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onChanged: (value) {
              setState(() => search = value);
            },
          ),
        ),

        // CATEGORY
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              categoryButton("All", ""),
              categoryButton("Carton", "carton-box"),
              categoryButton("Corrugated", "corrugated-box"),
              categoryButton("Duplex", "duplex-box"),
            ],
          ),
        ),

        SizedBox(height: 10),

        // PRODUCTS
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.60,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              var product = filteredProducts[index];
              int productId = int.parse(product["id"].toString());

              qtyControllers.putIfAbsent(
                  productId, () => TextEditingController(text: "1"));

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Expanded(
                        child: product["image_data"] != null
                            ? showImage(product["image_data"])
                            : Icon(Icons.image),
                      ),

                      SizedBox(height: 5),

                      Text(product["name"],
                          style: TextStyle(fontWeight: FontWeight.bold)),

                      Text("₹${product["price"]}"),

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
                        child: Text("Order Box"),
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
        ),
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
          ElevatedButton(onPressed: () {}, child: Text("Update Profile")),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, "/login"),
            child: Text("Logout"),
          ),
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
      appBar:
          AppBar(title: Text("Hello Customer"), backgroundColor: Colors.teal),
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
}