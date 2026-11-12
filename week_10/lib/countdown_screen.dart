import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  bool _versionA = true;

  late Stream<int> _stream;
  StreamSubscription<int>? _sub;

  int _left = 10;

  @override
  void initState() {
    super.initState();
    _stream = countdown(10);
  }

  void _startB() {
    _left = 10;
    _sub = countdown(10).listen((i) {
      if (!mounted) return;

      setState(() {
        _left = i;
      });
    });
  }

  void _switchVersion(bool versionA) {
    _sub?.cancel();
    _sub = null;

    setState(() {
      _versionA = versionA;
      _stream = countdown(10);
      _left = 10;
    });

    if (!versionA) {
      _startB();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Version A')),
                ButtonSegment(value: false, label: Text('Version B')),
              ],
              selected: {_versionA},
              onSelectionChanged: (values) {
                _switchVersion(values.first);
              },
            ),

            const SizedBox(height: 40),

            if (_versionA)
              StreamBuilder<int>(
                stream: _stream,
                builder: (context, snapshot) {
                  return Text(
                    '${snapshot.data ?? 10}',
                    style: Theme.of(context).textTheme.displayLarge,
                  );
                },
              )
            else
              Text('$_left', style: Theme.of(context).textTheme.displayLarge),
          ],
        ),
      ),
    );
  }
}
