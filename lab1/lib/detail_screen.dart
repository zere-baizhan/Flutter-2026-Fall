import 'dart:async';

import 'package:flutter/material.dart';

import 'models.dart';
import 'format.dart';
import 'routes.dart';

class DetailScreen extends StatefulWidget {
  final DetailArgs args;
  const DetailScreen({super.key, required this.args});
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Event event;
  late final Timer timer;
  @override
  void initState() {
    super.initState();
    event = widget.args.event;
    timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<bool> confirm(String title) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        ),
      ) ??
      false;
  Future<void> register() async {
    final name = widget.args.name.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter your name in Profile'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: widget.args.onProfile,
          ),
        ),
      );
      return;
    }
    final joined = event.contains(name);
    if (!joined && (event.isFull || event.isPast)) return;
    final yes = await confirm(joined ? 'Cancel registration?' : 'Register?');
    if (!mounted || !yes) return;
    final names = event.attendees;
    if (joined) {
      names.remove(name);
    } else {
      names.add(name);
    }
    setState(() => event = event.copyWith(attendees: names));
    widget.args.onUpdate(event);
  }

  Future<void> edit() async {
    final result = await Navigator.pushNamed<Event>(
      context,
      Routes.form,
      arguments: FormArgs(event),
    );
    if (!mounted || result == null) return;
    setState(() => event = result);
    widget.args.onEdit(result);
  }

  Future<void> delete() async {
    final yes = await confirm('Delete event?');
    if (!mounted || !yes) return;
    widget.args.onDelete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final joined = event.contains(widget.args.name);
    final (:taken, :free) = event.places;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit')
                edit();
              else
                delete();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            SizedBox(
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/community.png', fit: BoxFit.cover),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Chip(
                      avatar: Icon(event.category.icon),
                      label: Text(event.category.label),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Chip(
                      label: Text(
                        countdownText(countdown(event.date, DateTime.now())),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                event.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Names ($taken)'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text('Date: ${formatDate(event.date)}'),
                      Text(
                        event.isOnline
                            ? 'Online: ${event.place}'
                            : 'Place: ${event.place}',
                      ),
                      Text('Taken: $taken   Free: $free'),
                      if (event.description != null)
                        Text(event.description ?? ''),
                    ],
                  ),
                  event.attendees.isEmpty
                      ? const Center(child: Text('Nobody registered'))
                      : ListView(
                          children: [
                            for (final name in event.attendees)
                              ListTile(
                                leading: Icon(
                                  Icons.person,
                                  color: scheme.primary,
                                ),
                                title: Text(
                                  name == widget.args.name
                                      ? 'You ($name)'
                                      : name,
                                  style: TextStyle(
                                    fontWeight: name == widget.args.name
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                          ],
                        ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (!joined && (event.isFull || event.isPast))
                      ? null
                      : register,
                  child: Text(joined ? 'Cancel Registration' : 'Register'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
