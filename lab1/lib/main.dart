import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'routes.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode mode = ThemeMode.system;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'HomeSpace',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF388E3C)),
    ),
    darkTheme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF388E3C),
        brightness: Brightness.dark,
      ),
    ),
    themeMode: mode,
    routes: {
      Routes.home: (_) => HomeScreen(
        mode: mode,
        onThemeChanged: (value) => setState(() => mode = value),
      ),
    },
    onGenerateRoute: generateRoute,
    onUnknownRoute: (_) => MaterialPageRoute<void>(
      builder: (_) => const Scaffold(body: Center(child: Text('Not found'))),
    ),
  );
}
