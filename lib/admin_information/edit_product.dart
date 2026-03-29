import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class EditProductScreen extends StatefulWidget {
  final Map product;

  EditProductScreen({required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {

  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;
  late TextEditingController stockController;

  String boxType = "carton-box";
  File? image;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.product["name"]);
    priceController = TextEditingController(text: widget.product["price"].toString());
    descriptionController = TextEditingController(text: widget.product["description"] ?? "");
    stockController = TextEditingController(text: widget.product["stock"].toString());

    boxType = widget.product["box_type"];
  }

  Future pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  void updateProduct() async {
    var res = await ApiService.updateProduct(
      id: widget.product["id"].toString(),
      name: nameController.text,
      price: priceController.text,
      boxType: boxType,
      description: descriptionController.text,
      stock: stockController.text,
      imagePath: image?.path,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res["message"])),
    );

    if (res["status"] == "success") {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Product Name",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Price",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Stock",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

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

            ElevatedButton.icon(
              onPressed: pickImage,
              icon: Icon(Icons.image),
              label: Text("Change Image"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),

            SizedBox(height: 10),

            // 🔥 IMAGE PREVIEW (OLD + NEW)
            image != null
                ? Image.file(image!, height: 120)
                : (widget.product["image_data"] != null &&
                        widget.product["image_data"] != "")
                    ? Builder(
                        builder: (_) {
                          try {
                            String base64String = widget.product["image_data"];

                            base64String = base64String
                                .replaceAll("data:image/jpeg;base64,", "")
                                .replaceAll("data:image/png;base64,", "");

                            Uint8List bytes = base64Decode(base64String);

                            return Image.memory(bytes, height: 120);
                          } catch (e) {
                            print("Old image error: $e");
                            return Icon(Icons.broken_image, size: 80);
                          }
                        },
                      )
                    : Icon(Icons.image, size: 80),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: updateProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Update Product"),
            ),
          ],
        ),
      ),
    );
  }
}