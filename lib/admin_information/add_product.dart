import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {

  // ================= CONTROLLERS =================
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController stockController = TextEditingController();

  String boxType = "carton-box";

  File? image;
  final picker = ImagePicker();

  bool isLoading = false;

  // ================= PICK IMAGE =================
  Future pickImage() async {
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked != null) {
        setState(() {
          image = File(picked.path);
        });
      }
    } catch (e) {
      print("Image error: $e");
    }
  }

  // ================= SUBMIT =================
  void submit() async {

    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    var res = await ApiService.addProduct(
      name: nameController.text,
      price: priceController.text,
      boxType: boxType,
      imagePath: image!.path,
      description: descriptionController.text,
      stock: stockController.text.isEmpty ? "0" : stockController.text,
    );

    setState(() => isLoading = false);

    print(res); // DEBUG

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res["message"])),
    );

    if (res["status"] == "success") {
      Navigator.pop(context);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Product"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            // PRODUCT NAME
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Product Name",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            // PRICE
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Price",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            // DESCRIPTION
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            // STOCK
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Stock",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            // BOX TYPE
            DropdownButtonFormField<String>(
              value: boxType,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Box Type",
              ),
              items: [
                DropdownMenuItem(value: "carton-box", child: Text("Carton Box")),
                DropdownMenuItem(value: "corrugated-box", child: Text("Corrugated Box")),
                DropdownMenuItem(value: "duplex-box", child: Text("Duplex Box")),
              ],
              onChanged: (val) {
                setState(() => boxType = val!);
              },
            ),

            SizedBox(height: 20),

            // IMAGE BUTTON
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: Icon(Icons.image),
              label: Text("Select Image"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),

            SizedBox(height: 10),

            // IMAGE PREVIEW
            if (image != null)
              Image.file(image!, height: 120),

            SizedBox(height: 20),

            // SUBMIT BUTTON
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text("Add Product"),
                  ),
          ],
        ),
      ),
    );
  }
}