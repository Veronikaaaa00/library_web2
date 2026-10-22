import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Библиотека',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Каталог библиотеки',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Формы, валидация, связи сущностей и сохранение данных между перезагрузками.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () => context.go('/books'),
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Книги'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.go('/authors'),
                  icon: const Icon(Icons.person),
                  label: const Text('Авторы'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.go('/genres'),
                  icon: const Icon(Icons.category),
                  label: const Text('Жанры'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.go('/publishers'),
                  icon: const Icon(Icons.business),
                  label: const Text('Издательства'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.go('/readers'),
                  icon: const Icon(Icons.badge),
                  label: const Text('Читатели'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
