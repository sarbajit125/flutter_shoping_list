import 'package:flutter/material.dart';
import 'package:flutter_shoping_list/models/grocery_item.dart';

class GroceryListItem extends StatelessWidget {
  const GroceryListItem({required this.item, super.key});
  final GroceryItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                color: item.category.color,
              ),
              Text(item.name)
            ],
          ),
        ),
        const Spacer(),
        Text(item.quantity.toString()),
      ],
    );
  }
}
