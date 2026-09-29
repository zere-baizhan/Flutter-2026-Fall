import 'data.dart';
import 'models.dart';
import 'catalogue.dart';
import 'shelf_state.dart';

void main() {
  final books = rawBooks
      .map((json) => Book.fromJson(json))
      .toList();

  final library = Library([...books]);

  library.open();

  print('Every title:');
  print(library.everyTitle);

  print('\nBooks after 2010:');
  print(library.booksAfter2010);

  print('\nAverage pages:');
  print(library.averagePages);

  print('\nBooks by author:');
  print(library.booksByAuthor);

  print('\nAuthor names:');
  print(library.authorNames);

  print('\nGenres:');
  print(library.genres);

  print('\nCountry of Clean Code:');
  print(library.countryOf('Clean Code'));

  print('\nCountry of Design Patterns:');
  print(library.countryOf('Design Patterns'));

  print('\nDisplay list:');
  for (final line in library.displayList) {
    print(line);
  }

  print('\nRecord:');
  final stats = statsOf(books);
  print(stats);
  print('Count: ${stats.count}');
  print('Average pages: ${stats.avgPages}');

  print('\nShelf states:');
  print(describe(const Empty()));
  print(describe(Ready(books)));
  print(describe(const Broken('Database error')));
}