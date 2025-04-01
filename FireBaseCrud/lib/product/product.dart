import 'package:firebasecrud/pages/dashboard.dart';
import 'package:firebasecrud/services/database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Employee extends StatefulWidget {
  @override
  State<Employee> createState() => _EmployeeState();
}

class _EmployeeState extends State<Employee> {
  TextEditingController materialnamecontroller = TextEditingController();
  TextEditingController stockcodecontroller = TextEditingController();
  TextEditingController quantitycontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Ürün Kayıt Formu",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(
              left: 20.0, top: 30.0, right: 20.0, bottom: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ürün Adı",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5.0),
              Container(
                padding: const EdgeInsets.only(left: 10.0),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: materialnamecontroller,
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
              SizedBox(height: 15.0),
              Text(
                "Stok Kodu",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5.0),
              Container(
                padding: const EdgeInsets.only(left: 10.0),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: stockcodecontroller,
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
              SizedBox(height: 15.0),
              Text(
                "Adet",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5.0),
              Container(
                padding: const EdgeInsets.only(left: 10.0),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: quantitycontroller,
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
              SizedBox(height: 25.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final product =ProductModel(
                        materialName: materialnamecontroller.text,
                        stockCode: stockcodecontroller.text,
                        quantity:  int.tryParse(quantitycontroller.text) ?? 0,
                      );
                      await DatabaseHelper().insertProduct(product);
                      print("Veritabanına eklenen ürün: ${product.toMap()}");
                      // DashboardScreen'e yönlendirme
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DashboardScreen()),
                      );
                      Fluttertoast.showToast(
                        msg: "Ürün başarıyla eklendi!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    } catch (e) {
                      Fluttertoast.showToast(
                        msg: "Bir hata oluştu: $e",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 2,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      print("Hata: $e");
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.check_circle,
                        size: 40.0,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Ekle",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
