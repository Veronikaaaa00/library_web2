import 'package:flutter/material.dart';

class IdOption {
  const IdOption({required this.id, required this.label});
  final int id;
  final String label;
}

class IdMultiSelectField extends StatelessWidget {
  const IdMultiSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.validator,
  });

  final String label;
  final List<IdOption> options;
  final List<int> value;
  final ValueChanged<List<int>> onChanged;
  final FormFieldValidator<List<int>>? validator;

  @override
  Widget build(BuildContext context) {
    return FormField<List<int>>(
      initialValue: List<int>.from(value),
      validator: validator,
      builder: (field) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            errorText: field.errorText,
          ),
          child: options.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Нет доступных значений'),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: options.map((o) {
                    final selected = field.value!.contains(o.id);
                    return FilterChip(
                      label: Text(o.label),
                      selected: selected,
                      onSelected: (_) {
                        final next = [...field.value!];
                        selected ? next.remove(o.id) : next.add(o.id);
                        field.didChange(next);
                        onChanged(next);
                      },
                    );
                  }).toList(),
                ),
        );
      },
    );
  }
}
