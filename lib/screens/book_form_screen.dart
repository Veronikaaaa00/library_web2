import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/author.dart';
import '../models/book.dart';
import '../models/genre.dart';
import '../models/publisher.dart';
import '../repositories/author_repository.dart';
import '../repositories/book_repository.dart';
import '../repositories/genre_repository.dart';
import '../repositories/publisher_repository.dart';
import '../state/book_list_notifier.dart';
import '../validation/validators.dart';
import '../widgets/entity_form_scaffold.dart';
import '../widgets/id_multi_select_field.dart';

class BookFormScreen extends StatefulWidget {
  const BookFormScreen({super.key, this.id});

  final int? id;

  bool get isEditing => id != null;

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _title = TextEditingController();
  final _isbn = TextEditingController();
  final _year = TextEditingController();
  final _pages = TextEditingController();
  final _copiesTotal = TextEditingController();
  final _copiesAvailable = TextEditingController();

  int? _publisherId;
  List<int> _authorIds = [];
  List<int> _genreIds = [];
  List<Publisher> _publishers = [];
  List<Author> _authors = [];
  List<Genre> _genres = [];
  List<Book> _allBooks = [];
  Book? _existing;
  var _loading = true;
  String? _isbnUniqueError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final books = context.read<BookRepository>();
    final authors = context.read<AuthorRepository>();
    final genres = context.read<GenreRepository>();
    final publishers = context.read<PublisherRepository>();

    final results = await Future.wait([
      publishers.findAll(),
      authors.findAll(),
      genres.findAll(),
      books.findAll(),
      if (widget.isEditing) books.findById(widget.id!) else Future.value(null),
    ]);

    _publishers = results[0] as List<Publisher>;
    _authors = results[1] as List<Author>;
    _genres = results[2] as List<Genre>;
    _allBooks = results[3] as List<Book>;
    if (widget.isEditing) {
      _existing = results[4] as Book?;
      final book = _existing;
      if (book != null) {
        _title.text = book.title;
        _isbn.text = book.isbn;
        _year.text = '${book.year}';
        _pages.text = '${book.pages}';
        _copiesTotal.text = '${book.copiesTotal}';
        _copiesAvailable.text = '${book.copiesAvailable}';
        _publisherId = book.publisherId;
        _authorIds = List<int>.from(book.authorIds);
        _genreIds = List<int>.from(book.genreIds);
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  /// Каскад: при выборе издательства сужаем авторов и жанры
  /// до тех, что встречаются у книг этого издательства.
  List<Author> get _cascadedAuthors {
    if (_publisherId == null) return _authors;
    final ids = _allBooks
        .where((b) => !b.isDeleted && b.publisherId == _publisherId)
        .expand((b) => b.authorIds)
        .toSet();
    if (ids.isEmpty) return _authors;
    final filtered = _authors.where((a) => ids.contains(a.id)).toList();
    // Сохраняем уже выбранных, даже если они вне каскада.
    final selected = _authors.where((a) => _authorIds.contains(a.id));
    final map = {for (final a in [...filtered, ...selected]) a.id: a};
    return map.values.toList();
  }

  List<Genre> get _cascadedGenres {
    if (_publisherId == null) return _genres;
    final ids = _allBooks
        .where((b) => !b.isDeleted && b.publisherId == _publisherId)
        .expand((b) => b.genreIds)
        .toSet();
    if (ids.isEmpty) return _genres;
    final filtered = _genres.where((g) => ids.contains(g.id)).toList();
    final selected = _genres.where((g) => _genreIds.contains(g.id));
    final map = {for (final g in [...filtered, ...selected]) g.id: g};
    return map.values.toList();
  }

  void _onPublisherChanged(int? value) {
    setState(() {
      _publisherId = value;
      final allowedAuthors = _cascadedAuthors.map((a) => a.id).toSet();
      final allowedGenres = _cascadedGenres.map((g) => g.id).toSet();
      _authorIds = _authorIds.where(allowedAuthors.contains).toList();
      _genreIds = _genreIds.where(allowedGenres.contains).toList();
    });
  }

  Future<bool> _save() async {
    setState(() => _isbnUniqueError = null);
    final books = context.read<BookRepository>();
    final taken = await books.isIsbnTaken(_isbn.text, excludeId: widget.id);
    if (taken) {
      setState(() => _isbnUniqueError = 'ISBN уже используется');
      return false;
    }

    final draft = Book(
      id: widget.id ?? 0,
      title: _title.text.trim(),
      isbn: _isbn.text.trim(),
      year: int.parse(_year.text.trim()),
      pages: int.parse(_pages.text.trim()),
      publisherId: _publisherId!,
      authorIds: _authorIds,
      genreIds: _genreIds,
      copiesTotal: int.parse(_copiesTotal.text.trim()),
      copiesAvailable: int.parse(_copiesAvailable.text.trim()),
      deletedAt: _existing?.deletedAt,
    );

    if (widget.isEditing) {
      await books.update(draft);
    } else {
      await books.create(draft);
    }
    if (!mounted) return false;
    await context.read<BookListNotifier>().load();
    if (!mounted) return false;
    context.go('/books');
    return true;
  }

  @override
  void dispose() {
    _title.dispose();
    _isbn.dispose();
    _year.dispose();
    _pages.dispose();
    _copiesTotal.dispose();
    _copiesAvailable.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return EntityFormScaffold(
        title: widget.isEditing ? 'Изменить книгу' : 'Новая книга',
        fields: const [],
        isLoading: true,
        onSubmit: () async => false,
      );
    }

    if (widget.isEditing && _existing == null) {
      return EntityFormScaffold(
        title: 'Книга не найдена',
        fields: [
          const Text('Запись отсутствует.'),
          FilledButton(
            onPressed: () => context.go('/books'),
            child: const Text('К списку'),
          ),
        ],
        onSubmit: () async => false,
      );
    }

    return EntityFormScaffold(
      title: widget.isEditing ? 'Изменить книгу' : 'Новая книга',
      submitLabel: widget.isEditing ? 'Сохранить' : 'Создать',
      onSubmit: _save,
      fields: [
        TextFormField(
          controller: _title,
          decoration: const InputDecoration(
            labelText: 'Название',
            border: OutlineInputBorder(),
          ),
          validator: Validators.compose([
            (v) => Validators.required(v, label: 'Название'),
            (v) => Validators.maxLength(v, 200, label: 'Название'),
            (v) => Validators.minLength(v, 2, label: 'Название'),
          ]),
        ),
        TextFormField(
          controller: _isbn,
          decoration: InputDecoration(
            labelText: 'ISBN',
            border: const OutlineInputBorder(),
            errorText: _isbnUniqueError,
          ),
          validator: (v) => _isbnUniqueError ?? Validators.isbn(v),
        ),
        TextFormField(
          controller: _year,
          decoration: const InputDecoration(
            labelText: 'Год',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: Validators.year,
        ),
        TextFormField(
          controller: _pages,
          decoration: const InputDecoration(
            labelText: 'Страниц',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (v) => Validators.positiveInt(v, label: 'Страниц'),
        ),
        TextFormField(
          controller: _copiesTotal,
          decoration: const InputDecoration(
            labelText: 'Всего экземпляров',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (v) =>
              Validators.positiveInt(v, label: 'Всего экземпляров'),
        ),
        TextFormField(
          controller: _copiesAvailable,
          decoration: const InputDecoration(
            labelText: 'Доступно',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (v) {
            final base =
                Validators.nonNegativeInt(v, label: 'Доступно');
            if (base != null) return base;
            final avail = int.parse(v!.trim());
            final total = int.tryParse(_copiesTotal.text.trim()) ?? 0;
            if (avail > total) {
              return 'Доступно не может превышать всего экземпляров';
            }
            return null;
          },
        ),
        DropdownButtonFormField<int>(
          key: ValueKey('publisher-$_publisherId'),
          initialValue: _publisherId,
          decoration: const InputDecoration(
            labelText: 'Издательство',
            border: OutlineInputBorder(),
          ),
          items: _publishers
              .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
              .toList(),
          onChanged: _onPublisherChanged,
          validator: (v) => v == null ? 'Выберите издательство' : null,
        ),
        if (_publisherId != null)
          Text(
            'Авторы и жанры сужены по книгам выбранного издательства.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        IdMultiSelectField(
          key: ValueKey('authors-$_publisherId-${_cascadedAuthors.length}'),
          label: 'Авторы',
          value: _authorIds,
          options: _cascadedAuthors
              .map((a) => IdOption(id: a.id, label: a.fullName))
              .toList(),
          onChanged: (v) => setState(() => _authorIds = v),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Выберите хотя бы одного автора' : null,
        ),
        IdMultiSelectField(
          key: ValueKey('genres-$_publisherId-${_cascadedGenres.length}'),
          label: 'Жанры',
          value: _genreIds,
          options: _cascadedGenres
              .map((g) => IdOption(id: g.id, label: g.name))
              .toList(),
          onChanged: (v) => setState(() => _genreIds = v),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Выберите хотя бы один жанр' : null,
        ),
      ],
    );
  }
}
