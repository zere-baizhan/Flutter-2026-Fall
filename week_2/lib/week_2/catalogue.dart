import 'models.dart';

class Library {
  final List<LibraryItem> items;

  Library(this.items);

  void add(LibraryItem item) {
    items.add(item);
  }

  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) {
        return item;
      }
    }

    return null;
  }

  String countryOf(String title) {
    return findByTitle(title)?.author.country ?? 'unknown';
  }

  late final DateTime openedAt;

  void open() {
    openedAt = DateTime.now();
  }

  String? _cachedReport;

  String get report {
  final cached = _cachedReport;

  if (cached != null) {
    return cached;
  }

  final newReport = 'Library contains ${items.length} items';
  _cachedReport = newReport;

  return newReport;
}

  List<String> get everyTitle =>
      items.map((item) => item.title).toList();

  List<Book> get booksAfter2010 =>
      items.whereType<Book>().where((book) => book.year > 2010).toList();

  double get averagePages {
    final books = items.whereType<Book>().toList();

    if (books.isEmpty) {
      return 0;
    }

    return books.fold<int>(
          0,
          (sum, book) => sum + book.pages,
        ) /
        books.length;
  }

  Map<String, int> get booksByAuthor {
    final result = <String, int>{};

    for (final book in items.whereType<Book>()) {
      result[book.author.name] =
          (result[book.author.name] ?? 0) + 1;
    }

    return result;
  }

  Set<String> get authorNames =>
      items.whereType<Book>().map((book) => book.author.name).toSet();

  Set<Genre> get genres =>
      items.whereType<Book>().map((book) => book.genre).toSet();

  List<String> get displayList => [
        'CATALOGUE',
        for (final book in items.whereType<Book>())
          '${book.title} (${book.year})',
        ...items.whereType<Book>().map((book) => book.author.name),
        if (items.whereType<Book>().any((book) => book.pages == 0))
          '(incomplete data)',
      ];
}