
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _confirmClear(BuildContext context) async{
    final confirmed=await showDialog<bool>(
      context: context,
      builder:(dialogContext){
        return AlertDialog(
          title: const Text('Clear cart?'),
          content: const Text('U sure u wanna remove all books?',
          ),
          actions:[
            TextButton(onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: (){
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
    if (!context.mounted) return;

    if (confirmed == true) {
      context.read<Cart>().clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(tooltip: 'Clearn cart', icon: const Icon(Icons.delete_outline),onPressed: ()=> _confirmClear(context),),
        ],
      ),

      body: Consumer<Cart>(
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.payments_outlined),
            SizedBox(width: 8),
            Text('Total:'),
          ],
        ),
        builder: (context, cart, child) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: cart.items.map((book) {
                    return ListTile(
                      title: Text(book.title),
                      subtitle: Text(
                        '${book.price} ₸',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('×${cart.qtyOf(book)}'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              cart.increment(book);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              cart.remove(book);
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    child!,
                    const SizedBox(width: 12),
                    Text(
                      '${cart.total} ₸',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
