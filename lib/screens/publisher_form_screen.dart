import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/publisher.dart';
import '../repositories/publisher_repository.dart';
import '../state/publisher_list_notifier.dart';
import '../validation/validators.dart';
import '../widgets/entity_form_scaffold.dart';

class PublisherFormScreen extends StatefulWidget {
  const PublisherFormScreen({super.key, this.id});

  final int? id;
  bool get isEditing => id != null;

  @override
  State<PublisherFormScreen> createState() => _PublisherFormScreenState();
}

class _PublisherFormScreenState extends State<PublisherFormScreen> {
  final _name = TextEditingController();
  final _country = TextEditingController();
  Publisher? _existing;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.isEditing) {
      _existing =
          await context.read<PublisherRepository>().findById(widget.id!);
      if (_existing != null) {
        _name.text = _existing!.name;
        _country.text = _existing!.country;
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<bool> _save() async {
    final repo = context.read<PublisherRepository>();
    final draft = Publisher(
      id: widget.id ?? 0,
      name: _name.text.trim(),
      country: _country.text.trim(),
      deletedAt: _existing?.deletedAt,
    );
    if (widget.isEditing) {
      await repo.update(draft);
    } else {
      await repo.create(draft);
    }
    if (!mounted) return false;
    await context.read<PublisherListNotifier>().load();
    if (!mounted) return false;
    context.go('/publishers');
    return true;
  }

  @override
  void dispose() {
    _name.dispose();
    _country.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return EntityFormScaffold(
        title: widget.isEditing ? 'Изменить издательство' : 'Новое издательство',
        fields: const [],
        isLoading: true,
        onSubmit: () async => false,
      );
    }
    return EntityFormScaffold(
      title: widget.isEditing ? 'Изменить издательство' : 'Новое издательство',
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
            (v) => Validators.maxLength(v, 120, label: 'Название'),
          ]),
        ),
        TextFormField(
          controller: _country,
          decoration: const InputDecoration(
            labelText: 'Страна',
            border: OutlineInputBorder(),
          ),
          validator: Validators.compose([
            (v) => Validators.required(v, label: 'Страна'),
            (v) => Validators.maxLength(v, 80, label: 'Страна'),
          ]),
        ),
      ],
    );
  }
}
