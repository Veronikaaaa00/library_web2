import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final location =
        GoRouter.of(context).routeInformationProvider.value.uri.path;

    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      drawer: NavigationDrawer(
        selectedIndex: _selectedIndex(location),
        onDestinationSelected: (index) {
          Navigator.of(context).pop();
          switch (index) {
            case 0:
              context.go('/');
            case 1:
              context.go('/books');
            case 2:
              context.go('/authors');
            case 3:
              context.go('/genres');
            case 4:
              context.go('/publishers');
            case 5:
              context.go('/readers');
          }
        },
        children: const [
          DrawerHeader(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Библиотека',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: Text('Главная'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: Text('Книги'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: Text('Авторы'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: Text('Жанры'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business),
            label: Text('Издательства'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge),
            label: Text('Читатели'),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }

  int _selectedIndex(String location) {
    if (location.startsWith('/books')) return 1;
    if (location.startsWith('/authors')) return 2;
    if (location.startsWith('/genres')) return 3;
    if (location.startsWith('/publishers')) return 4;
    if (location.startsWith('/readers')) return 5;
    return 0;
  }
}
