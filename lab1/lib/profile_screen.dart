import 'package:flutter/material.dart';

import 'models.dart';

class ProfileScreen extends StatefulWidget {
  final Profile profile;
  final int registrations;
  final ThemeMode mode;
  final ValueChanged<Profile> onChanged;
  final ValueChanged<ThemeMode> onThemeChanged;
  const ProfileScreen({
    super.key,
    required this.profile,
    required this.registrations,
    required this.mode,
    required this.onChanged,
    required this.onThemeChanged,
  });
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController name;
  late final TextEditingController group;
  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.profile.name);
    group = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile.name != oldWidget.profile.name)
      name.text = widget.profile.name;
    if (widget.profile.group != oldWidget.profile.group)
      group.text = widget.profile.group;
  }

  @override
  void dispose() {
    name.dispose();
    group.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Icon(Icons.account_circle, size: 72),
      TextFormField(
        controller: name,
        decoration: const InputDecoration(labelText: 'Name'),
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (value) =>
            widget.onChanged(widget.profile.copyWith(name: value.trim())),
      ),
      TextFormField(
        controller: group,
        decoration: const InputDecoration(labelText: 'Apartment / Group'),
        textInputAction: TextInputAction.done,
        validator: (value) => RegExp(r'^[a-zA-Z0-9 -]*$').hasMatch(value ?? '')
            ? null
            : 'Use letters and numbers',
        onFieldSubmitted: (value) {
          if (RegExp(r'^[a-zA-Z0-9 -]*$').hasMatch(value)) {
            widget.onChanged(widget.profile.copyWith(group: value.trim()));
          }
        },
      ),
      const SizedBox(height: 16),
      Text('You are on ${widget.registrations} lists'),
      const SizedBox(height: 16),
      const Text('Theme'),
      Wrap(
        spacing: 8,
        children: [
          for (final mode in ThemeMode.values)
            ChoiceChip(
              label: Text(mode.name),
              selected: widget.mode == mode,
              onSelected: (_) => widget.onThemeChanged(mode),
            ),
        ],
      ),
    ],
  );
}
