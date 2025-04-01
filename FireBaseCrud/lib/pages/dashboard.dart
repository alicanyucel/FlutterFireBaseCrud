import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebasecrud/services/database.dart';
import 'package:path/path.dart';
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
          title: Text("Sayım Fişi"),
          backgroundColor: Colors.red,
          actions: [
            IconButton(
              icon: Icon(Icons.calculate),
              onPressed: () {

              },
            ),
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {

              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.search), text: "Ürün Ara"),
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

class SearchTab extends StatefulWidget {
  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  List<ProductModel> searchResults = [];
  TextEditingController searchController = TextEditingController();

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    final dbHelper = DatabaseHelper(); // DatabaseHelper sınıfının bir örneğini oluşturuyoruz
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'materialName LIKE ? OR stockCode LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    setState(() {
      searchResults = maps.map((map) => ProductModel.fromMap(map)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: searchProducts,
            decoration: const InputDecoration(
              labelText: "Ara",
              border: UnderlineInputBorder(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final product = searchResults[index];
                return ListTile(
                  title: Text("Ürün Adı ${product.materialName} Stok Kodu (${product.stockCode})"),
                  subtitle: Text("Adet: ${product.quantity}"),
                 
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ListTab extends StatefulWidget {
  @override
  _ListTabState createState() => _ListTabState();
}


class _ListTabState extends State<ListTab> {
  Future<List<ProductModel>> getProduct() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) {
      return ProductModel.fromMap(maps[i]);
    });
  }

  Future<void> deleteProducts(int id) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  void _showDeleteDialog(BuildContext context, int id, String fullName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Silme Onayı"),
          content: Text("$fullName adlı ürünü silmek istiyor musunuz?"),
          actions: <Widget>[
            TextButton(
              child: Text("Hayır"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Evet"),
              onPressed: () async {
                Navigator.of(context).pop();
                await deleteProducts(id);
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: getProduct(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Bir hata oluştu: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Veri bulunamadı"));
        }

        final products = snapshot.data!;

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              leading: Icon(Icons.shopping_bag),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stok Kodu: ${product.stockCode}'),
                  Text(
                    'Ürün Adı: ${product.materialName}',
                    style: TextStyle(color: Colors.red),
                  ),
                  Text('Adet: ${product.quantity}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Silme butonu
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    tooltip: 'Sil',
                    onPressed: () {
                      _showDeleteDialog(
                        context,
                        product.id!,
                        '${product.materialName} ${product.stockCode}',
                      );
                    },
                  ),

                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.blue),
                    tooltip: 'Yenile',
                    onPressed: () {
                      setState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}


class SummaryTab extends StatelessWidget {
  Future<int> getProductCount() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT SUM(quantity) as totalQuantity FROM products;');
    return result.isNotEmpty && result.first['totalQuantity'] != null
        ? result.first['totalQuantity'] as int
        : 0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: getProductCount(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Hata: ${snapshot.error}"));
        } else {
          return Center(
            child: Text(
              "Toplam Ürün Miktarı: ${snapshot.data}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          );
        }
      },
    );
  }
}

