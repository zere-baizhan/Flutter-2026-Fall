import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'dev_checks.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

const _runDevChecks = bool.fromEnvironment('DEV_CHECKS');

Future<void> main() async {
  if (_runDevChecks) {
    checkModel();
    await checkRepository(UserRepository(ApiClient(Client())));
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => UsersModel(UserRepository(ApiClient(Client())))..load(),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Users API',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const UsersScreen(),
    );
  }
}
