import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/book.dart';
import 'models/cart.dart';
import 'cart_badge.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState(); }

  class _BooksScreenState extends State<BooksScreen>{
      String searchText='';

      @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');

    final filteredBooks=books.where((book){
      final query=searchText.toLowerCase();

      return book.title.toLowerCase().contains(query) || book.author.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Books'), actions: const [CartBadge()],
      bottom: PreferredSize(preferredSize: const Size.fromHeight(65), 
      child: Padding(padding: const EdgeInsets.all(8),
      child: TextField(
        onChanged: (value){
          setState(() {
            searchText=value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search Books...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          border:OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      ),
      ),
      
      ),
      body: ListView(
        children: filteredBooks.map((book) {
          debugPrint('row ${book.title}');

          final isAdded = context.watch<Cart>().items.contains(book);

          return ListTile(
            title: Text(book.title),
            subtitle: Text('${book.author} • ${book.price} ₸'),
            trailing: isAdded
                ? const Text('Added')
                : OutlinedButton(
                    onPressed: () {
                      final ok=context.read<Cart>().add(book);

                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                          content: Text('Added'),
                          duration: Duration(seconds: 1),
    ),
  );
}
                    },
                    child: const Text('Add'),
                  ),
          );
        }).toList(),
      ),
    );
  }
  }
  

  

