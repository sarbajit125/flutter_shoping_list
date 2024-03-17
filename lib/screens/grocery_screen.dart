import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_shoping_list/data/categories.dart';
import 'package:flutter_shoping_list/models/grocery_item.dart';
import 'package:flutter_shoping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryCategoryScreen extends StatefulWidget {
  const GroceryCategoryScreen({super.key});
  @override
  State<GroceryCategoryScreen> createState() => _GroceryCategoryScreenState();
}

class _GroceryCategoryScreenState extends State<GroceryCategoryScreen> {
  List<GroceryItem> groceryList = [];
  var isLoading = true;
  String? _error;
  void _loadItems() async {
    final uri = Uri.https(
        'flutter-prep-5ebfb-default-rtdb.firebaseio.com', 'shopping-list.json');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      if (response.body != "null") {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<GroceryItem> loadedItems = [];
        for (final item in responseData.entries) {
          final localCategory = categories.entries.firstWhere(
              (element) => element.value.name == item.value['category']);
          loadedItems.add(GroceryItem(
              id: item.key,
              name: item.value["name"],
              quantity: item.value['quantity'],
              category: localCategory.value));
        }
        setState(() {
          groceryList = loadedItems;
          isLoading = false;
        });
      } else {
        setState(() {
           isLoading = false;
           groceryList = [];
        });
      }
    } else {
      setState(() {
        _error = "API request failed";
      });
    }
  }

  Future<void> _removeItem(GroceryItem item) async {
    final uri = Uri.https('flutter-prep-5ebfb-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    setState(() {
      isLoading = true;
    });
    final response = await http.delete(uri);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        groceryList.remove(item);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        _error = "DELETE request failed";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _addItem() async {
    final newItem =
        await Navigator.of(context).push<GroceryItem>(MaterialPageRoute(
      builder: (context) => const NewItemScreen(),
    ));
    if (newItem != null) {
      setState(() {
        groceryList.add(newItem);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('NO items added yet'),
    );
    if (isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }
    if (groceryList.isNotEmpty) {
      content = ListView.builder(
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(groceryList[index].id),
          onDismissed: (direction) {
            _removeItem(groceryList[index]);
          },
          child: ListTile(
            title: Text(groceryList[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: groceryList[index].category.color,
            ),
            trailing: Text(
              groceryList[index].quantity.toString(),
            ),
          ),
        ),
        itemCount: groceryList.length,
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Groceries"),
          actions: [
            IconButton(onPressed: _addItem, icon: const Icon(Icons.add))
          ],
        ),
        body: content);
  }
}
