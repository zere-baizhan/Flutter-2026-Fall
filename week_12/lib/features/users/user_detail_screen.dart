import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/storage/secure_store.dart';
import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  Future<void> _open(BuildContext context, Uri uri) async {
    var ok = false;
    try {
      ok = await launchUrl(uri);
    } on PlatformException {
      ok = false;
    }
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No app can open this')));
    }
  }

  Future<void> _copyToken(BuildContext context) async {
    final token = await context.read<SecureStore>().readToken();
    if (!context.mounted) return;
    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No token — not signed in')));
      return;
    }
    await Clipboard.setData(ClipboardData(text: token));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Token copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    final a = user.address;
    final website = user.website;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.badge),
            title: Text('@${user.username}'),
            subtitle: Text('id ${user.id}'),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(user.email),
            trailing: const Icon(Icons.open_in_new),
            onTap: () =>
                _open(context, Uri(scheme: 'mailto', path: user.email)),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(user.phone),
            subtitle: Text(user.phoneDigits),
            trailing: const Icon(Icons.open_in_new),
            onTap: () =>
                _open(context, Uri(scheme: 'tel', path: user.phoneDigits)),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(website ?? '—'),
            trailing: website == null ? null : const Icon(Icons.open_in_new),
            onTap: website == null
                ? null
                : () => _open(context, Uri.parse('https://$website')),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text('${a.street}, ${a.suite}'),
            subtitle: Text('${a.city} ${a.zipcode}'),
          ),
          ListTile(
            leading: const Icon(Icons.place),
            title: Text('${a.geo.lat}, ${a.geo.lng}'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.business),
            title: Text(user.company.name),
            subtitle: Text(user.company.catchPhrase),
          ),
          if (kDebugMode) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.key),
              title: const Text('Copy token to clipboard'),
              subtitle: const Text('Debug builds only'),
              onTap: () => _copyToken(context),
            ),
          ],
        ],
      ),
    );
  }
}
