import '../models/book.dart';
import '../models/book_query.dart';
import '../models/page_result.dart';

abstract interface class BookRepository {
  Future<PageResult<Book>> find(BookQuery query);

  Future<List<Book>> findAll({bool includeDeleted = false});

  Future<Book?> findById(int id);

  Future<Book> create(Book book);

  Future<Book> update(Book book);

  Future<void> softDelete(int id);

  Future<void> hardDelete(int id);

  Future<void> restore(int id);

  Future<int> deleteMany(List<int> ids);

  Future<bool> isIsbnTaken(String isbn, {int? excludeId});

  Future<int> countByPublisher(int publisherId);

  Future<int> countByAuthor(int authorId);

  Future<int> countByGenre(int genreId);
}
