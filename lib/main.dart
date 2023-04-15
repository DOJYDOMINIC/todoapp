import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('my_box');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _discriptionController = TextEditingController();

  List<Map<String, dynamic>> _items = [];

  final my_box = Hive.box('my_box');

  _refreshItem() {
    final data = my_box.keys.map((key) {
      final item = my_box.get(key);
      return {"key": key, "name": item["name"], "descrip": item["descrip"]};
    }).toList();

    setState(() {
      _items = data.reversed.toList();
    });
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await my_box.add(newItem);
    _refreshItem();
  }

  Future<void> _updateItem(int itemkey, Map<String, dynamic> item) async {
    await my_box.put(itemkey, item);
    _refreshItem();
  }

  Future<void> _deleteItem(int itemkey) async {
    await my_box.delete(itemkey);
    _refreshItem();
  }

  void _showform(BuildContext context, itemkey) async {
    if (itemkey != null) {
      final existigItem =
          _items.firstWhere((element) => element['key'] == itemkey);
      _titleController.text = existigItem['name'];
      _discriptionController.text = existigItem['descrip'];
    }

    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        child: Column(
          children: [
            TextField(
              controller: _titleController,
            ),
            TextField(
              controller: _discriptionController,
            ),
            ElevatedButton(
                onPressed: () async {
                  if (itemkey == null) {
                    _createItem({
                      "name": _titleController.text,
                      "descrip": _discriptionController.text
                    });
                  }

                  if (itemkey != null) {
                    _updateItem(itemkey, {
                      'name': _titleController.text.trim(),
                      'descrip': _discriptionController.text.trim(),
                    });
                  }

                  _titleController.text = '';
                  _discriptionController.text = '';
                  Navigator.of(context).pop();
                },
                child: Text(itemkey == null ? 'Create New' : 'Update'))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo'),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final currentitem = _items[index];
          return Card(
            child: ListTile(
              title: Text(currentitem['name']),
              subtitle: Text(currentitem['descrip']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: () => _showform(context, currentitem['key']),
                      icon: Icon(Icons.edit)),
                  IconButton(
                      onPressed: () => _deleteItem(currentitem['key']),
                      icon: Icon(Icons.delete))
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showform(context, null),
        child: Icon(Icons.add),
      ),
    );
  }
}
