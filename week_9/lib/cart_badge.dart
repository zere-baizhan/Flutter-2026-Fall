import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('badge build');

    final count = context.select<Cart, int>(
      (cart) => cart.count,
    );

    return IconButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/cart');
      },
      icon: Badge(
        label: Text('$count'),
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}
