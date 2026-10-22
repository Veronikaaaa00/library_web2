import 'package:flutter_test/flutter_test.dart';
import 'package:library_web/models/book.dart';
import 'package:library_web/models/book_query.dart';
import 'package:library_web/repositories/persistent_book_repository.dart';
import 'package:library_web/repositories/persistent_publisher_repository.dart';
import 'package:library_web/repositories/related_records_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('книга сохраняется между экземплярами репозитория', () async {
    final prefs = await SharedPreferences.getInstance();
    final first = PersistentBookRepository(prefs);
    await first.create(
      const Book(
        id: 0,
        title: 'Тест',
        isbn: '9780000000002',
        year: 2020,
        pages: 100,
        publisherId: 1,
        authorIds: [1],
        genreIds: [1],
        copiesTotal: 2,
        copiesAvailable: 1,
      ),
    );

    final second = PersistentBookRepository(prefs);
    final found = await second.find(const BookQuery(search: 'Тест', size: 50));
    expect(found.items.any((b) => b.title == 'Тест'), isTrue);
  });

  test('уникальность ISBN', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = PersistentBookRepository(prefs);
    expect(await repo.isIsbnTaken('978-5-17-090123-1'), isTrue);
    expect(await repo.isIsbnTaken('9780000000099'), isFalse);
  });

  test('нельзя удалить издательство со связанными книгами', () async {
    final prefs = await SharedPreferences.getInstance();
    final books = PersistentBookRepository(prefs);
    final publishers = PersistentPublisherRepository(prefs, books);
    expect(
      () => publishers.softDelete(1),
      throwsA(isA<RelatedRecordsException>()),
    );
  });
}
