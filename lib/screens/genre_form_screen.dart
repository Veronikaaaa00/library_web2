import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/genre.dart';
import '../repositories/genre_repository.dart';
import '../state/genre_list_notifier.dart';
import '../validation/validators.dart';
import '../widgets/entity_form_scaffold.dart';

class GenreFormScreen extends StatefulWidget {
  const GenreFormScreen({super.key, this.id});

  final int? id;
  bool get isEditing => id != null;

  @override
  State<GenreFormScreen> createState() => _GenreFormScreenState();
}

class _GenreFormScreenState extends State<GenreFormScreen> {
  final _name = TextEditingController();
  Genre? _existing;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.isEditing) {
      _existing = await context.read<GenreRepository>().findById(widget.id!);
      if (_existing != null) _name.text = _existing!.name;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<bool> _save() async {
    final repo = context.read<GenreRepository>();
    final draft = Genre(
      id: widget.id ?? 0,
      name: _name.text.trim(),
      deletedAt: _existing?.deletedAt,
    );
    if (widget.isEditing) {
      await repo.update(draft);
    } else {
      await repo.create(draft);
    }
    if (!mounted) return false;
    await context.read<GenreListNotifier>().load();
    if (!mounted) return false;
    context.go('/genres');
    return true;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return EntityFormScaffold(
        title: widget.isEditing ? 'Изменить жанр' : 'Новый жанр',
        fields: const [],
        isLoading: true,
        onSubmit: () async => false,
      );
    }
    return EntityFormScaffold(
      title: widget.isEditing ? 'Изменить жанр' : 'Новый жанр',
      submitLabel: widget.isEditing ? 'Сохранить' : 'Создать',
      onSubmit: _save,
      fields: [
        TextFormField(
          controller: _name,
          decoration: const InputDecoration(
            labelText: 'Название',
            border: OutlineInputBorder(),
          ),
          validator: Validators.compose([
            (v) => Validators.required(v, label: 'Название'),
            (v) => Validators.maxLength(v, 80, label: 'Название'),
            (v) => Validators.minLength(v, 2, label: 'Название'),
          ]),
        ),
      ],
    );
  }
}
