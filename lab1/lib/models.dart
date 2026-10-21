import 'package:flutter/material.dart';

enum EventCategory {
  community('Community', Icons.groups),
  sport('Sport', Icons.sports_soccer),
  cleaning('Cleaning', Icons.cleaning_services),
  education('Education', Icons.school),
  entertainment('Entertainment', Icons.movie);

  const EventCategory(this.label, this.icon);
  final String label;
  final IconData icon;
  Color color(ColorScheme scheme) => switch (this) {
    EventCategory.community => scheme.primary,
    EventCategory.sport => scheme.secondary,
    EventCategory.cleaning => scheme.tertiary,
    EventCategory.education => scheme.primary,
    EventCategory.entertainment => scheme.secondary,
  };
}

class Event {
  final String title;
  final EventCategory category;
  final DateTime date;
  final String place;
  final int limit;
  final List<String> _attendees;
  final bool isOnline;
  final String? description;
  final bool isFavorite;

  const Event._(
    this.title,
    this.category,
    this.date,
    this.place,
    this.limit,
    this._attendees,
    this.isOnline,
    this.description,
    this.isFavorite,
  );
  factory Event({
    required String title,
    required EventCategory category,
    required DateTime date,
    required String place,
    required int limit,
    required List<String> attendees,
    bool isOnline = false,
    String? description,
    bool isFavorite = false,
  }) => Event._(
    title,
    category,
    date,
    place,
    limit,
    List.unmodifiable(attendees),
    isOnline,
    description,
    isFavorite,
  );
  factory Event.empty() => Event(
    title: '',
    category: EventCategory.community,
    date: DateTime.now().add(const Duration(days: 1)),
    place: '',
    limit: 20,
    attendees: [],
  );
  List<String> get attendees => List.unmodifiable(_attendees);
  int get count => _attendees.length;
  int get freePlaces => limit - count;
  bool get isFull => freePlaces <= 0;
  bool get isPast => date.isBefore(DateTime.now());
  bool contains(String name) => name.isNotEmpty && _attendees.contains(name);
  ({int taken, int free}) get places => (taken: count, free: freePlaces);
  Event copyWith({
    String? title,
    EventCategory? category,
    DateTime? date,
    String? place,
    int? limit,
    List<String>? attendees,
    bool? isOnline,
    String? description,
    bool clearDescription = false,
    bool? isFavorite,
  }) => Event(
    title: title ?? this.title,
    category: category ?? this.category,
    date: date ?? this.date,
    place: place ?? this.place,
    limit: limit ?? this.limit,
    attendees: attendees ?? _attendees,
    isOnline: isOnline ?? this.isOnline,
    description: clearDescription ? null : description ?? this.description,
    isFavorite: isFavorite ?? this.isFavorite,
  );
}

class Profile {
  final String name;
  final String group;
  const Profile({required this.name, required this.group});
  const Profile.empty() : name = '', group = '';
  Profile copyWith({String? name, String? group}) =>
      Profile(name: name ?? this.name, group: group ?? this.group);
}

sealed class Countdown {
  const Countdown();
}

class Upcoming extends Countdown {
  final Duration time;
  const Upcoming(this.time);
}

class Started extends Countdown {
  final Duration time;
  const Started(this.time);
}

class Ended extends Countdown {
  const Ended();
}

Countdown countdown(DateTime start, DateTime now) {
  if (now.isBefore(start)) return Upcoming(start.difference(now));
  final elapsed = now.difference(start);
  if (elapsed.inHours < 1) return Started(elapsed);
  return const Ended();
}

String countdownText(Countdown value) => switch (value) {
  Upcoming(:final time) => 'In ${time.inDays}d ${time.inHours % 24}h',
  Started(:final time) => 'Started ${time.inMinutes}m ago',
  Ended() => 'Ended',
};
