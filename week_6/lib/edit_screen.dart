import 'package:flutter/material.dart';

import 'students.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key, required this.student});

  final Student student;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late String _name = widget.student.name;
  bool _allowDiscard = false;
  bool get _dirty => _name != widget.student.name;

  Future<void> _handleBack(bool didPop) async {
    if (didPop) return;

    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved changes. Do you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (discard == true) {
      setState(() {
    _allowDiscard = true;
  });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Student')),
      body: PopScope(
        canPop: !_dirty || _allowDiscard,
        onPopInvokedWithResult: (didPop, result) async {
          await _handleBack(didPop);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                  hintText: 'Enter a new name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(_name);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
