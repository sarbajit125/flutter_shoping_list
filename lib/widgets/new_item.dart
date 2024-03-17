import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_shoping_list/data/categories.dart';
import 'package:flutter_shoping_list/models/category.dart';
import 'package:flutter_shoping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});

  @override
  State<NewItemScreen> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String _enteredName = "";
  var _enteredQuantity = 0;
  var selectedCategory = categories[Categories.vegetables]!;
  var isLoading = false;
  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isLoading = true;
      });
      final uri = Uri.https('flutter-prep-5ebfb-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final response = await http.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "name": _enteredName,
            "quantity": _enteredQuantity,
            "category": selectedCategory.name
          }));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (!context.mounted) {
          return;
        }
        Navigator.of(context).pop(GroceryItem(
            id: responseData['name'],
            name: _enteredName,
            quantity: _enteredQuantity,
            category: selectedCategory));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a new item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  onSaved: (newValue) {
                    _enteredName = newValue!;
                  },
                  decoration: const InputDecoration(label: Text('Name')),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1) {
                      return 'Must be between 2 to 50 chars';
                    }
                    return null;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          label: Text("Quantity"),
                        ),
                        initialValue: '1',
                        onSaved: (newValue) {
                          _enteredQuantity = int.parse(newValue!);
                        },
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'invalid quantity';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: selectedCategory,
                        items: categories.entries
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: e.value.color,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Text(e.value.name)
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: isLoading
                            ? null
                            : () => _formKey.currentState!.reset(),
                        child: const Text('Reset')),
                    ElevatedButton(
                        onPressed: isLoading ? null : _saveItem,
                        child: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator())
                            : const Text("Save")),
                  ],
                )
              ],
            )),
      ),
    );
  }
}
