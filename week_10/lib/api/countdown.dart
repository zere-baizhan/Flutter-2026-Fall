import 'package:flutter/material.dart';

Stream<int> countdown(int from) async* {
  for (int i = from; i >= 0; i--) {
    await Future.delayed(const Duration(seconds: 1));
    yield i;
    debugPrint('tick $i');
  }
}
