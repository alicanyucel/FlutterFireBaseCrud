import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Dashboard"),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.search), text: "Arama"),
              Tab(icon: Icon(Icons.list), text: "Liste"),
              Tab(icon: Icon(Icons.summarize), text: "Toplam"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SearchTab(),
            ListTab(),
            SummaryTab(),
          ],
        ),
      ),
    );
  }
}

class SearchTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: "Ara",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ],
      ),
    );
  }
}

class ListTab extends StatelessWidget {
  final List<String> items = List.generate(10, (index) => "Öğe ${index + 1}");

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.label),
          title: Text(items[index]),
        );
      },
    );
  }
}

class SummaryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Toplama Sayfası İçeriği", style: TextStyle(fontSize: 20)),
    );
  }
}
