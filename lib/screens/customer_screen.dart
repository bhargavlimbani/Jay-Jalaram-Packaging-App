import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CustomerScreen extends StatefulWidget {
  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {

  List products = [];
  List cart = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  void loadProducts() async {
    var data = await ApiService.getProducts();
    setState(() {
      products = data;
    });
  }

  void addToCart(product) {
    setState(() {
      cart.add(product);
    });
  }

  void placeOrder() async {
    List items = cart.map((p) => {
      "product_id": p["id"],
      "quantity": 1
    }).toList();

    await ApiService.placeOrder(items);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order placed"))
    );

    setState(() {
      cart.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Customer Dashboard")),

      body: Column(
        children: [

          ElevatedButton(
            onPressed: placeOrder,
            child: Text("Place Order (${cart.length})"),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, i) {
                var p = products[i];
                return ListTile(
                  title: Text(p["name"]),
                  subtitle: Text("Rs. ${p["price"]}"),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => addToCart(p),
                  ),
                );
              },
            ),
          )

        ],
      ),
    );
  }
}