import '../data/seed_data.dart';
import '../models/book.dart';
import '../models/book_query.dart';
import '../models/page_result.dart';
import 'book_repository.dart';

class InMemoryBookRepository implements BookRepository {
  final List<Book> _books = [...seedBooks];
  int _nextId = seedBooks.length + 1;

  @override
  Future<PageResult<Book>> find(BookQuery q) async {
    await Future.delayed(const Duration(milliseconds: 250));

    // Служебный запрос для демонстрации состояния ошибки на защите.
    if (q.search.trim() == '__error__') {
      throw StateError('Сбой источника данных');
    }

    var rows = _books.where((b) => q.includeDeleted || !b.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where(
            (b) =>
                b.title.toLowerCase().contains(needle) ||
                b.isbn.toLowerCase().contains(needle),
          )
          .toList();
    }
    if (q.genreId != null) {
      rows = rows.where((b) => b.genreIds.contains(q.genreId)).toList();
    }
    if (q.publisherId != null) {
      rows = rows.where((b) => b.publisherId == q.publisherId).toList();
    }
    if (q.yearFrom != null) {
      rows = rows.where((b) => b.year >= q.yearFrom!).toList();
    }
    if (q.yearTo != null) {
      rows = rows.where((b) => b.year <= q.yearTo!).toList();
    }

    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'year' => a.year.compareTo(b.year),
        'pages' => a.pages.compareTo(b.pages),
        'isbn' => a.isbn.compareTo(b.isbn),
        _ => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      };
      return q.sortAscending ? result : -result;
    });

    final total = rows.length;
    final from = (q.page - 1) * q.size;
    final to = (from + q.size) > total ? total : (from + q.size);
    final items = from >= total ? <Book>[] : rows.sublist(from, to);
    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<List<Book>> findAll({bool includeDeleted = false}) async {
    return _books.where((b) => includeDeleted || !b.isDeleted).toList();
  }

  @override
  Future<Book?> findById(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    for (final book in _books) {
      if (book.id == id) return book;
    }
    return null;
  }

  @override
  Future<Book> create(Book book) async {
    final created = Book(
      id: _nextId++,
      title: book.title,
      isbn: book.isbn,
      year: book.year,
      pages: book.pages,
      publisherId: book.publisherId,
      authorIds: List<int>.from(book.authorIds),
      genreIds: List<int>.from(book.genreIds),
      copiesTotal: book.copiesTotal,
      copiesAvailable: book.copiesAvailable,
    );
    _books.add(created);
    return created;
  }

  @override
  Future<Book> update(Book book) async {
    final i = _books.indexWhere((b) => b.id == book.id);
    if (i == -1) {
      throw StateError('Книга ${book.id} не найдена');
    }
    _books[i] = book;
    return book;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _books.indexWhere((b) => b.id == id);
    if (i == -1) {
      throw StateError('Книга $id не найдена');
    }
    _books[i] = _books[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    _books.removeWhere((b) => b.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _books.indexWhere((b) => b.id == id);
    if (i == -1) {
      throw StateError('Книга $id не найдена');
    }
    _books[i] = _books[i].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final i = _books.indexWhere((b) => b.id == id && !b.isDeleted);
      if (i != -1) {
        _books[i] = _books[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }

  @override
  Future<bool> isIsbnTaken(String isbn, {int? excludeId}) async {
    final needle = isbn.replaceAll(RegExp(r'[\s-]'), '').toLowerCase();
    return _books.any(
      (b) =>
          !b.isDeleted &&
          b.id != excludeId &&
          b.isbn.replaceAll(RegExp(r'[\s-]'), '').toLowerCase() == needle,
    );
  }

  @override
  Future<int> countByPublisher(int publisherId) async {
    return _books
        .where((b) => !b.isDeleted && b.publisherId == publisherId)
        .length;
  }

  @override
  Future<int> countByAuthor(int authorId) async {
    return _books
        .where((b) => !b.isDeleted && b.authorIds.contains(authorId))
        .length;
  }

  @override
  Future<int> countByGenre(int genreId) async {
    return _books
        .where((b) => !b.isDeleted && b.genreIds.contains(genreId))
        .length;
  }
}
