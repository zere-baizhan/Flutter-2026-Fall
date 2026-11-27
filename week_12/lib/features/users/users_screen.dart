import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../settings/settings_model.dart';
import '../settings/settings_screen.dart';
import 'new_user_screen.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: const _UsersBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const NewUserScreen())),
        icon: const Icon(Icons.person_add),
        label: const Text('New user'),
      ),
    );
  }
}

class _UsersBody extends StatelessWidget {
  const _UsersBody();

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    final city = context.watch<SettingsModel>().city;

    if (m.loading && m.items.isEmpty) return const LoadingView();

    final shown = city == null
        ? m.items
        : m.items.where((u) => u.address.city == city).toList();

    return switch (m.error) {
      null => Column(
        children: [
          if (m.fromCache) StaleBanner(loading: m.loading, onRetry: m.load),
          Expanded(
            child: RefreshIndicator(onRefresh: m.load, child: UserList(shown)),
          ),
        ],
      ),
      NoConnectionException() => Offline(onRetry: m.load),
      NotFoundException() || UnauthorizedException() => const MessageView(
        icon: Icons.block,
        title: 'Not available',
        message: 'The server refused this request.',
      ),
      ServerException(:final status) => ServerError(status, onRetry: m.load),
      BadResponseException() => const GenericError(),
    };
  }
}

class StaleBanner extends StatelessWidget {
  const StaleBanner({super.key, required this.loading, required this.onRetry});

  final bool loading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return MaterialBanner(
      backgroundColor: colors.tertiaryContainer,
      leading: Icon(Icons.cloud_off, color: colors.onTertiaryContainer),
      content: Text(
        'Saved data · no connection',
        style: TextStyle(color: colors.onTertiaryContainer),
      ),
      actions: [
        TextButton(
          onPressed: loading ? null : onRetry,
          child: loading
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Retry'),
        ),
      ],
    );
  }
}

class UserList extends StatelessWidget {
  const UserList(this.users, {super.key});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final u = users[i];
        return ListTile(
          leading: CircleAvatar(child: Text(u.name.isEmpty ? '?' : u.name[0])),
          title: Text(u.name),
          subtitle: Text('${u.email} · ${u.address.city}'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => UserDetailScreen(user: u)),
          ),
        );
      },
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (retry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class Offline extends StatelessWidget {
  const Offline({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => MessageView(
    icon: Icons.wifi_off,
    title: 'No connection',
    message: 'Check your internet and try again.',
    onRetry: onRetry,
  );
}

class ServerError extends StatelessWidget {
  const ServerError(this.status, {super.key, required this.onRetry});

  final int status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => MessageView(
    icon: Icons.cloud_off,
    title: 'Server error ($status)',
    message: 'Their server had a problem. Try again in a moment.',
    onRetry: onRetry,
  );
}

class GenericError extends StatelessWidget {
  const GenericError({super.key});

  @override
  Widget build(BuildContext context) => const MessageView(
    icon: Icons.bug_report,
    title: 'Something went wrong',
    message: 'We could not read the server\'s answer. This is a bug.',
  );
}
