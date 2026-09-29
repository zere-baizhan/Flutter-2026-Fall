import 'dart:async';

import 'package:flutter/material.dart';

class StopwatchCard extends StatefulWidget {
  const StopwatchCard({super.key});

  @override
  State<StopwatchCard> createState() => _StopwatchCardState();
}

class _StopwatchCardState extends State<StopwatchCard> {
  // 1. STATE
  int _seconds = 0;
  Timer? _timer;

  // 2. START
  void _start() {
    if (_timer != null) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  // 3. STOP
  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  // 4. RESET
  void _reset() {
    _stop();

    setState(() {
      _seconds = 0;
    });
  }

  // 5. ПРЕВРАЩАЕМ СЕКУНДЫ В mm:ss
  String get _formattedTime {
    final minutes = _seconds ~/ 60;
    final seconds = _seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // 6. ОБЯЗАТЕЛЬНО ОСТАНАВЛИВАЕМ TIMER
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 7. UI
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(_formattedTime, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(onPressed: _start, child: const Text('Start')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: _stop, child: const Text('Stop')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: _reset, child: const Text('Reset')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
