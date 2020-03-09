import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo/models/item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lembretes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>();

  HomePage() {
    items = [];
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskCtrl = TextEditingController();

  void addItem() {
    if (newTaskCtrl.text.isEmpty) return;

    setState(() {
      widget.items.add(
        Item(
          title: newTaskCtrl.text,
          done: false,
        ),
      );
      save();
      newTaskCtrl.clear();
      Navigator.of(context).pop();
    });
  }

  void createDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Novo Lembrete"),
          content: TextFormField(
            keyboardType: TextInputType.text,
            controller: newTaskCtrl,
            decoration: InputDecoration(
              hintText: "Título",
            ),
          ),
          // showDatePicker(
          //   context: context,
          //   initialDate: DateTime.now(),
          //   firstDate: DateTime(2020),
          //   lastDate: DateTime(2050),
          //   builder: (BuildContext context, Widget child) {
          //     return Theme(
          //       data: ThemeData.light(),
          //       child: child,
          //     );
          //   },
          // );
          actions: [
            FlatButton(
              child: Text("Feito"),
              onPressed: addItem,
            )
          ],
        );
      },
    );
  }

  void remove(index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  Future loadData() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');
    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  _HomePageState() {
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lembretes"),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext ctxt, int index) {
          final item = widget.items[index];

          return Dismissible(
            child: CheckboxListTile(
              title: Text(item.title),
              onChanged: (bool value) {
                setState(() {
                  item.done = value;
                  save();
                });
              },
              value: item.done,
            ),
            key: Key(item.title),
            background: Container(
              color: Theme.of(context).primaryColorLight,
            ),
            onDismissed: (direction) {
              remove(index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
