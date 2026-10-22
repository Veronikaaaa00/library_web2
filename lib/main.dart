import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'repositories/author_repository.dart';
import 'repositories/book_repository.dart';
import 'repositories/genre_repository.dart';
import 'repositories/persistent_author_repository.dart';
import 'repositories/persistent_book_repository.dart';
import 'repositories/persistent_genre_repository.dart';
import 'repositories/persistent_publisher_repository.dart';
import 'repositories/persistent_reader_repository.dart';
import 'repositories/publisher_repository.dart';
import 'repositories/reader_repository.dart';
import 'router.dart';
import 'state/author_list_notifier.dart';
import 'state/book_list_notifier.dart';
import 'state/genre_list_notifier.dart';
import 'state/publisher_list_notifier.dart';
import 'state/reader_list_notifier.dart';
import 'storage/storage_meta.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final prefs = await SharedPreferences.getInstance();
  final meta = await StorageMeta.open(prefs);

  final books = PersistentBookRepository(prefs);
  final authors = PersistentAuthorRepository(prefs);
  final genres = PersistentGenreRepository(prefs, books);
  final publishers = PersistentPublisherRepository(prefs, books);
  final readers = PersistentReaderRepository(prefs);

  runApp(
    MultiProvider(
      providers: [
        Provider<BookRepository>.value(value: books),
        Provider<AuthorRepository>.value(value: authors),
        Provider<GenreRepository>.value(value: genres),
        Provider<PublisherRepository>.value(value: publishers),
        Provider<ReaderRepository>.value(value: readers),
        Provider<StorageMeta>.value(value: meta),
        ChangeNotifierProvider(
          create: (_) => BookListNotifier(books)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthorListNotifier(authors)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => GenreListNotifier(genres)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => PublisherListNotifier(publishers)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReaderListNotifier(readers)..load(),
        ),
      ],
      child: const LibraryApp(),
    ),
  );
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Библиотека',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E8C),
        ),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
      builder: (context, child) {
        final message = context.read<StorageMeta>().resetMessage;
        return _MigrationBanner(
          message: message,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class _MigrationBanner extends StatefulWidget {
  const _MigrationBanner({required this.message, required this.child});

  final String? message;
  final Widget child;

  @override
  State<_MigrationBanner> createState() => _MigrationBannerState();
}

class _MigrationBannerState extends State<_MigrationBanner> {
  var _visible = true;

  @override
  Widget build(BuildContext context) {
    final show = widget.message != null && _visible;
    return Column(
      children: [
        if (show)
          Material(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: SafeArea(
              bottom: false,
              child: ListTile(
                dense: true,
                title: Text(widget.message!),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _visible = false),
                ),
              ),
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
