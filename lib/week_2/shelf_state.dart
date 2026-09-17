import 'models.dart';

sealed class ShelfState {
  const ShelfState();
}

class Empty extends ShelfState {
  const Empty();
}

class Ready extends ShelfState {
  final List<Book> books;

  const Ready(this.books);
}

class Broken extends ShelfState {
  final String message;

  const Broken(this.message);
}

String describe(ShelfState state) {
  return switch (state) {
    Empty() => 'Shelf is empty',
    Ready(books: final books) => 'Shelf is ready with ${books.length} books',
    Broken(message: final message) => 'Shelf is broken: $message',
  };
}

({int count, double avgPages}) statsOf(List<Book> books) {
  if (books.isEmpty) {
    return (count: 0, avgPages: 0);
  }

  final totalPages = books.fold<int>(
    0,
    (sum, book) => sum + book.pages,
  );

  return (
    count: books.length,
    avgPages: totalPages / books.length,
  );
}