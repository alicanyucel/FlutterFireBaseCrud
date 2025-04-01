import 'package:firebasecrud/pages/dashboard.dart';
import 'package:firebasecrud/services/database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Product extends StatefulWidget {
  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController materialNameController = TextEditingController();
  TextEditingController stockCodeController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ürün Kayıt Formu",
          style: TextStyle(color: Colors.blue, fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTextField("Ürün Adı", materialNameController, "Ürün adını giriniz"),
                buildTextField("Stok Kodu", stockCodeController, "Stok kodunu giriniz"),
                buildTextField("Adet", quantityController, "Adet giriniz", isNumeric: true, isQuantity: true),
                const SizedBox(height: 25.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final product = ProductModel(
                            materialName: materialNameController.text,
                            stockCode: stockCodeController.text,
                            quantity: int.tryParse(quantityController.text) ?? 0,
                          );
                          await DatabaseHelper().insertProduct(product);
                          print("Veritabanına eklenen ürün: \${product.toMap()}");
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DashboardScreen()),
                          );
                          Fluttertoast.showToast(
                            msg: "Ürün başarıyla eklendi!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                          );
                        } catch (e) {
                          Fluttertoast.showToast(
                            msg: "Bir hata oluştu: \$e",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                        }
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle, size: 40.0),
                        SizedBox(width: 8),
                        Text("Ekle", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, String hintText, {bool isNumeric = false, bool isQuantity = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black, fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5.0),
          TextFormField(
            controller: controller,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "$label boş bırakılamaz";
              }
              if (isQuantity) {
                final int? number = int.tryParse(value);
                if (number == null || number <= 0) {
                  return "$label 0'dan büyük bir sayı olmalıdır";
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
