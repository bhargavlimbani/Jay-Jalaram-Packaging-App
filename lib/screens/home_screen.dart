// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class HomeScreen extends StatefulWidget {
//   final Map<String, dynamic>? user;

//   HomeScreen({this.user});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {

//   Map<String, String>? selectedContact;

//   List<Map<String, String>> contacts = [
//     {"name": "Maheshbhai", "phone": "9429315940"},
//     {"name": "Bhargav", "phone": "6355990290"},
//     {"name": "Vijaybhai", "phone": "9909309111"},
//   ];

//   void launchCall(String phone) async {
//     final Uri url = Uri.parse("tel:$phone");
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//     }
//   }

//   void launchWhatsApp(String phone) async {
//     final Uri url = Uri.parse("https://wa.me/91$phone");
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(
//       appBar: AppBar(title: Text("Jalaram Packaging")),

//       body: SingleChildScrollView(
//         child: Column(
//           children: [

//             // 🔥 HERO SECTION
//             Container(
//               padding: EdgeInsets.all(20),
//               color: Colors.amber[50],
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [

//                   Text("Ocean-Inspired Storefront",
//                       style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),

//                   SizedBox(height: 10),

//                   Text(
//                     "Premium Corrugated Packaging",
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),

//                   SizedBox(height: 10),

//                   Text(
//                     "Explore industrial boxes, shipping cartons, printed packaging, and custom-made orders.",
//                   ),

//                   SizedBox(height: 20),

//                   Row(
//                     children: [

//                       ElevatedButton(
//                         onPressed: () {
//                           // Navigate to products
//                         },
//                         child: Text("Explore Products"),
//                       ),

//                       SizedBox(width: 10),

//                       ElevatedButton(
//                         onPressed: () {
//                           // Navigate to custom order
//                         },
//                         child: Text("Custom Box"),
//                       ),

//                     ],
//                   ),

//                   SizedBox(height: 20),

//                   if (widget.user != null && widget.user!["role"] == "customer")
//                     Container(
//                       padding: EdgeInsets.all(10),
//                       color: Colors.amber[200],
//                       child: Text("Welcome back, ${widget.user!["name"]}"),
//                     )
//                 ],
//               ),
//             ),

//             SizedBox(height: 20),

//             // 🔥 PRODUCT CARDS
//             Padding(
//               padding: EdgeInsets.all(10),
//               child: Column(
//                 children: [

//                   buildCard("Small Box", "Lightweight packaging"),
//                   buildCard("Medium Box", "Shipping ready"),
//                   buildCard("Large Box", "Heavy duty"),

//                 ],
//               ),
//             ),

//             SizedBox(height: 20),

//             // 🔥 FEATURES
//             Padding(
//               padding: EdgeInsets.all(10),
//               child: Column(
//                 children: [

//                   Text("Why Customers Stay",
//                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

//                   SizedBox(height: 10),

//                   feature("Browse packaging by category"),
//                   feature("Add multiple products"),
//                   feature("Upload custom design"),
//                   feature("Track admin responses"),

//                 ],
//               ),
//             ),

//             SizedBox(height: 20),

//             // 🔥 CONTACT SECTION
//             Padding(
//               padding: EdgeInsets.all(10),
//               child: Column(
//                 children: [

//                   Text("Contact Us",
//                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

//                   ...contacts.map((c) => ListTile(
//                     title: Text(c["name"]!),
//                     subtitle: Text(c["phone"]!),
//                     onTap: () {
//                       setState(() {
//                         selectedContact = c;
//                       });
//                     },
//                   )),

//                   SizedBox(height: 10),

//                   InkWell(
//                     onTap: () async {
//                       final url = Uri.parse("https://maps.app.goo.gl/Kn4HBcCYZhP6kJVR7");
//                       await launchUrl(url);
//                     },
//                     child: Text(
//                       "Shapar Veraval, Rajkot",
//                       style: TextStyle(color: Colors.blue),
//                     ),
//                   )
//                 ],
//               ),
//             ),

//           ],
//         ),
//       ),

//       // 🔥 CONTACT POPUP
//       bottomSheet: selectedContact != null
//           ? Container(
//               padding: EdgeInsets.all(20),
//               color: Colors.white,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [

//                   Text(selectedContact!["name"]!,
//                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

//                   Text(selectedContact!["phone"]!),

//                   SizedBox(height: 10),

//                   ElevatedButton(
//                     onPressed: () => launchCall(selectedContact!["phone"]!),
//                     child: Text("Call"),
//                   ),

//                   ElevatedButton(
//                     onPressed: () => launchWhatsApp(selectedContact!["phone"]!),
//                     child: Text("WhatsApp"),
//                   ),

//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         selectedContact = null;
//                       });
//                     },
//                     child: Text("Cancel"),
//                   )

//                 ],
//               ),
//             )
//           : null,
//     );
//   }

//   // 🔧 Helper Widgets

//   Widget buildCard(String title, String subtitle) {
//     return Card(
//       child: ListTile(
//         title: Text(title),
//         subtitle: Text(subtitle),
//       ),
//     );
//   }

//   Widget feature(String text) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 5),
//       padding: EdgeInsets.all(10),
//       color: Colors.grey[200],
//       child: Text(text),
//     );
//   }
// }