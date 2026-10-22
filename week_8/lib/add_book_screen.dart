import 'package:flutter/material.dart';
import 'models/book.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _pages = TextEditingController();
  final _year = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _pages.dispose();
    _year.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final book = Book(
      title: _title.text.trim(),
      author: _author.text.trim(),
      pages: int.parse(_pages.text.trim()),
      year: int.tryParse(_year.text.trim()),
    );
    Navigator.pop(context, book);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Add book')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  textInputAction: TextInputAction.next,
                  onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  validator: (v) => (v ?? '').trim().length < 2 ? 'At least 2 characters' : null,
                ),
                TextFormField(
                  controller: _author,
                  decoration: const InputDecoration(labelText: 'Author'),
                  textInputAction: TextInputAction.next,
                  onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Author is required' : null,
                ),
                TextFormField(
                  controller: _pages,
                  decoration: const InputDecoration(labelText: 'Pages'),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    if (n == null || n <= 0) return 'A whole number above 0';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _year,
                  decoration: const InputDecoration(labelText: 'Year (optional)'),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _save(),
                  onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return null;
                    final year = int.tryParse(value);
                    if (year == null || year < 1450 || year > DateTime.now().year) {
                      return 'Year must be between 1450 and ${DateTime.now().year}';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(onPressed: _save, child: const Text('Save')),
              ],
            ),
          ),
        ),
      );
}
