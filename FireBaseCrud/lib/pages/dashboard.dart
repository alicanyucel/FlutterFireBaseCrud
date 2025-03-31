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
  List<EmployeeModel> searchResults = [];
  TextEditingController searchController = TextEditingController();

  Future<void> searchEmployees(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    final dbHelper = DatabaseHelper(); // DatabaseHelper sınıfının bir örneğini oluşturuyoruz
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'firstName LIKE ? OR lastName LIKE ? OR address LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );

    setState(() {
      searchResults = List.generate(maps.length, (i) {
        return EmployeeModel.fromMap(maps[i]);
      });
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
            onChanged: searchEmployees,
            decoration: InputDecoration(
              labelText: "Ara",
              border: UnderlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final employee = searchResults[index];
                return ListTile(
                  title: Text("${employee.firstName} ${employee.lastName}"),
                  subtitle: Text(employee.address),
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
  Future<List<EmployeeModel>> getEmployees() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('employees');
    return List.generate(maps.length, (i) {
      return EmployeeModel.fromMap(maps[i]);
    });
  }

  Future<void> deleteEmployee(int id) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await db.delete('employees', where: 'id = ?', whereArgs: [id]);
  }

  void _showDeleteDialog(BuildContext context, int id, String fullName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Silme Onayı"),
          content: Text("$fullName adlı çalışanı silmek istiyor musunuz?"),
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
                await deleteEmployee(id);
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
    return FutureBuilder<List<EmployeeModel>>(
      future: getEmployees(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Bir hata oluştu: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Veri bulunamadı"));
        } else {
          final employees = snapshot.data!;
          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              return ListTile(
                leading: Icon(Icons.person),
                title: Text('${employee.firstName} ${employee.lastName}'),
                subtitle: Text(employee.address),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Sil',
                      onPressed: () {
                        _showDeleteDialog(
                          context,
                          employee.id!,
                          '${employee.firstName} ${employee.lastName}',
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
        }
      },
    );
  }
}


class SummaryTab extends StatelessWidget {
  Future<int> getEmployeeCount() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    // çalışan sayısını bulan sql sorgum
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM employees');
    return result.isNotEmpty ? result.first['count'] as int : 0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: getEmployeeCount(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        } else {
          return Center(
            child: Text(
              "Çalışan Sayısı: ${snapshot.data}",
              style: TextStyle(fontSize: 20),
            ),
          );
        }
      },
    );
  }
}
