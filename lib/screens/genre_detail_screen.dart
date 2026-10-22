import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/genre.dart';
import '../repositories/genre_repository.dart';
import '../widgets/app_scaffold.dart';

class GenreDetailScreen extends StatefulWidget {
  const GenreDetailScreen({super.key, required this.genreId});
  final int genreId;

  @override
  State<GenreDetailScreen> createState() => _GenreDetailScreenState();
}

class _GenreDetailScreenState extends State<GenreDetailScreen> {
  late Future<Genre?> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<GenreRepository>().findById(widget.genreId);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Жанр',
      body: FutureBuilder<Genre?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final g = snapshot.data;
          if (g == null) {
            return const Center(child: Text('Жанр не найден'));
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(g.name, style: Theme.of(context).textTheme.headlineMedium),
              if (g.isDeleted) const Chip(label: Text('Удалён')),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: () => context.go('/genres/${g.id}/edit'),
                icon: const Icon(Icons.edit),
                label: const Text('Изменить'),
              ),
            ],
          );
        },
      ),
    );
  }
}
