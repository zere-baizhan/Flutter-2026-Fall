import 'models.dart';

List<Event> createSeedEvents() {
  final today = DateTime.now();
  Event make(
    String title,
    EventCategory category,
    int days,
    int limit,
    int taken, {
    bool online = false,
    String? description,
  }) => Event(
    title: title,
    category: category,
    date: today.add(Duration(days: days)),
    place: online ? 'https://meet.example.com' : 'Community Hall',
    limit: limit,
    attendees: List.generate(taken, (i) => 'Resident ${i + 1}'),
    isOnline: online,
    description: description,
  );
  return [
    make(
      'Residents Meeting',
      EventCategory.community,
      1,
      20,
      12,
      description: 'Meeting for residents.',
    ),
    make('Cleaning Day', EventCategory.cleaning, 2, 30, 15),
    make('Yoga Class', EventCategory.sport, 3, 10, 8),
    make('Movie Night', EventCategory.entertainment, 4, 25, 25),
    make('Kids Workshop', EventCategory.education, 5, 15, 6),
    make('Football Match', EventCategory.sport, 6, 22, 14),
    make('Book Club', EventCategory.education, 7, 12, 5, online: true),
    make('Garden Day', EventCategory.cleaning, 8, 20, 10),
    make('Safety Training', EventCategory.education, 9, 30, 18),
    make('Cooking Class', EventCategory.community, 10, 15, 12),
    make('Board Games', EventCategory.entertainment, 11, 10, 4),
    make(
      'Community Party for Everyone Living in Our Building Today!',
      EventCategory.community,
      -2,
      50,
      40,
    ),
  ];
}
