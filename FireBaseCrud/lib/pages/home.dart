import 'package:firebasecrud/employee/employee.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Employee()),
          );
        },
        icon: Icon(Icons.add),
        label: Text('Çalışan Kayıt Formu'),
      ),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Flutter Firebase Crud Ali Can",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),

          ],
        ),
      ),
      body: Container(
        child: Column(
          children: [
            // İçerik buraya eklenecek
          ],
        ),
      ),

    );
  }
}
