import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class InvoiceService {
  static Future<Uint8List> generateInvoice(Map order) async {
    final pdf = pw.Document();

    List items = [];
    try {
      items = order["items"] != null
          ? List.from(order["items"])
          : [];
    } catch (e) {}

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [

            pw.Text("INVOICE",
                style: pw.TextStyle(
                    fontSize: 24, fontWeight: pw.FontWeight.bold)),

            pw.SizedBox(height: 10),

            pw.Text("Order ID: ${order["id"]}"),
            pw.Text("Customer: ${order["customer_name"]}"),
            pw.Text("Phone: ${order["customer_phone"]}"),

            pw.SizedBox(height: 20),

            pw.Text("Items:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),

            pw.SizedBox(height: 10),

            ...items.map((item) {
              return pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(item["name"] ?? ""),
                  pw.Text("Qty: ${item["quantity"] ?? 0}"),
                  pw.Text("₹${item["price"] ?? 0}"),
                ],
              );
            }).toList(),

            pw.Divider(),

            pw.Text("Total: ₹${order["total_price"]}",
                style: pw.TextStyle(fontSize: 18)),

            pw.SizedBox(height: 20),

            pw.Text("Thank you for your order!"),
          ],
        ),
      ),
    );

    return pdf.save();
  }
}