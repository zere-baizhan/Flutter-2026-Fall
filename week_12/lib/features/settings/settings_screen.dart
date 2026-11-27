import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_model.dart';
import '../profile/profile_screen.dart';
import '../users/users_model.dart';
import 'settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final users = context.watch<UsersModel>().items;

    final cities = {for (final u in users) u.address.city}.toList()..sort();
    final saved = settings.city;
    if (saved != null && !cities.contains(saved)) cities.insert(0, saved);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark mode'),
            value: settings.dark,
            onChanged: (v) => context.read<SettingsModel>().setDark(v),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String?>(
              initialValue: saved,
              decoration: const InputDecoration(
                labelText: 'Show users from',
                prefixIcon: Icon(Icons.location_city),
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All cities'),
                ),
                for (final c in cities)
                  DropdownMenuItem<String?>(value: c, child: Text(c)),
              ],
              onChanged: (c) => context.read<SettingsModel>().setCity(c),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profile photo'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () async {
              final auth = context.read<AuthModel>();
              Navigator.of(context).popUntil((route) => route.isFirst);
              await auth.logout();
            },
          ),
        ],
      ),
    );
  }
}
