import 'package:flutter/material.dart';

class TwoWayCounter extends StatefulWidget {
  const TwoWayCounter({super.key});

  @override
  State<TwoWayCounter> createState() => _TwoWayCounterState();
}

class _TwoWayCounterState extends State<TwoWayCounter> {
  // 1. STATE
  int _count = 0;
  bool _saving = false;

  // 2. ФУНКЦИЯ SAVE — ДО build()
  Future<void> _save() async {
    setState(() {
      _saving = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _saving = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved')));
  }

  // 3. UI
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // MINUS
            OutlinedButton(
              onPressed: _count == 0
                  ? null
                  : () {
                      setState(() {
                        _count--;
                      });
                    },
              child: const Text('-'),
            ),

            const SizedBox(width: 20),

            // NUMBER
            Text('$_count', style: const TextStyle(fontSize: 24)),

            const SizedBox(width: 20),

            // PLUS
            FilledButton(
              onPressed: () {
                setState(() {
                  _count++;
                });
              },
              child: const Text('+'),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // SAVE
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
