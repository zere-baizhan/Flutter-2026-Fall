import 'package:flutter/material.dart';

import 'models.dart';
import 'data.dart';
import 'format.dart';
import 'profile_screen.dart';
import 'routes.dart';

class HomeScreen extends StatefulWidget {
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onThemeChanged;
  const HomeScreen({
    super.key,
    required this.mode,
    required this.onThemeChanged,
  });
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Event> events;
  Profile profile = const Profile.empty();
  int tab = 0;
  String search = '';
  EventCategory? category;
  bool showPast = false;
  final searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    events = createSeedEvents();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void update(Event old, Event next) {
    setState(() {
      final i = events.indexOf(old);
      if (i != -1) events[i] = next;
    });
  }

  Future<void> add() async {
    final result = await Navigator.pushNamed<Event>(
      context,
      Routes.form,
      arguments: const FormArgs(),
    );
    if (!mounted || result == null) return;
    setState(() => events.add(result));
  }

  void open(Event item) {
    Event current = item;
    Navigator.pushNamed<void>(
      context,
      Routes.detail,
      arguments: DetailArgs(
        item,
        profile.name,
        (next) {
          update(current, next);
          current = next;
        },
        () {
          Navigator.pop(context);
          setState(() => tab = 2);
        },
        (next) {
          update(current, next);
          current = next;
        },
        () => setState(() => events.remove(current)),
      ),
    );
  }

  Future<bool> ask(String title) async =>
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
  Future<void> reset() async {
    if (!await ask('Reset all data?')) return;
    if (!mounted) return;
    setState(() {
      events = createSeedEvents();
      profile = const Profile.empty();
    });
  }

  Widget empty(String message, {VoidCallback? onClear}) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.inbox_outlined, size: 50),
        Text(message),
        if (onClear != null)
          TextButton(onPressed: onClear, child: const Text('Clear filters')),
      ],
    ),
  );
  Widget card(Event event) {
    final scheme = Theme.of(context).colorScheme;
    final free = event.freePlaces;
    return Card(
      child: InkWell(
        onTap: () => open(event),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(radius: 28, child: Icon(event.category.icon)),
                  if (event.isFull || free <= 5)
                    Positioned(
                      bottom: -9,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        color: scheme.surfaceContainerHighest,
                        child: Text(
                          event.isFull ? 'FULL' : '$free left',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(formatDate(event.date)),
                    Text(
                      event.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (event.description != null)
                      Text(
                        event.description ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => update(
                  event,
                  event.copyWith(isFavorite: !event.isFavorite),
                ),
                icon: Icon(
                  event.isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget listing() {
    final visible =
        events
            .where(
              (e) =>
                  e.title.toLowerCase().contains(search.toLowerCase()) &&
                  (category == null || e.category == category) &&
                  (showPast || !e.isPast) &&
                  (tab != 1 || e.isFavorite),
            )
            .toList()
          ..sort((a, b) {
            if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
            return a.date.compareTo(b.date);
          });
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: search.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        setState(() => search = '');
                      },
                    ),
            ),
            onChanged: (v) => setState(() => search = v),
          ),
        ),
        SizedBox(
          height: 54,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: category == null,
                onSelected: (_) => setState(() => category = null),
              ),
              for (final c in EventCategory.values)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: ChoiceChip(
                    label: Text(c.label),
                    selected: category == c,
                    onSelected: (_) => setState(() => category = c),
                  ),
                ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FilterChip(
            label: const Text('Show past'),
            selected: showPast,
            onSelected: (v) => setState(() => showPast = v),
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? empty(
                  tab == 1 ? 'No favourites or matches' : 'No matches',
                  onClear: () => setState(() {
                    search = '';
                    searchController.clear();
                    category = null;
                    showPast = false;
                  }),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      return ListView.separated(
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 4),
                        itemBuilder: (_, i) => card(visible[i]),
                      );
                    }
                    final columns = (constraints.maxWidth / 360).ceil();
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisExtent: 130,
                      ),
                      itemCount: visible.length,
                      itemBuilder: (_, i) => card(visible[i]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('HomeSpace')),
    drawer: Drawer(
      child: ListView(
        children: [
          const DrawerHeader(child: Text('HomeSpace')),
          ListTile(
            title: const Text('About'),
            leading: const Icon(Icons.info_outline),
            onTap: () {
              Navigator.pop(context);
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About'),
                  content: const Text('HomeSpace community events app'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Reset data'),
            leading: const Icon(Icons.restart_alt),
            onTap: () {
              Navigator.pop(context);
              reset();
            },
          ),
        ],
      ),
    ),
    body: tab == 2
        ? ProfileScreen(
            profile: profile,
            registrations: events.where((e) => e.contains(profile.name)).length,
            mode: widget.mode,
            onThemeChanged: widget.onThemeChanged,
            onChanged: (next) => setState(() => profile = next),
          )
        : listing(),
    floatingActionButton: tab == 0
        ? FloatingActionButton(onPressed: add, child: const Icon(Icons.add))
        : null,
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (i) => setState(() => tab = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.event), label: 'Events'),
        NavigationDestination(icon: Icon(Icons.favorite), label: 'Favorites'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      ],
    ),
  );
}
