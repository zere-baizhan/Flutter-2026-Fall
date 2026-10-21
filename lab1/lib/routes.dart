import 'package:flutter/material.dart';

import 'models.dart';
import 'detail_screen.dart';
import 'form_screen.dart';

class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
}

class DetailArgs {
  final Event event;
  final String name;
  final ValueChanged<Event> onUpdate;
  final VoidCallback onProfile;
  final ValueChanged<Event> onEdit;
  final VoidCallback onDelete;

  const DetailArgs(
    this.event,
    this.name,
    this.onUpdate,
    this.onProfile,
    this.onEdit,
    this.onDelete,
  );
}

class FormArgs {
  final Event? event;

  const FormArgs([this.event]);
}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.detail:
      final args = settings.arguments as DetailArgs;

      return MaterialPageRoute<void>(builder: (_) => DetailScreen(args: args));

    case Routes.form:
      final args = settings.arguments as FormArgs?;

      return MaterialPageRoute<Event>(
        builder: (_) => FormScreen(event: args?.event),
      );

    default:
      return MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Center(child: Text('Not found'))),
      );
  }
}
