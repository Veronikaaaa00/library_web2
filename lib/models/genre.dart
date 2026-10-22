import '../utils/json_utils.dart';

class Genre {
  final int id;
  final String name;
  final DateTime? deletedAt;

  const Genre({required this.id, required this.name, this.deletedAt});

  bool get isDeleted => deletedAt != null;

  Genre copyWith({
    String? name,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Genre(
      id: id,
      name: name ?? this.name,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Genre.fromJson(Map<String, dynamic> json) => Genre(
        id: asInt(json['id']),
        name: asString(json['name']),
        deletedAt: asDateTime(json['deletedAt']),
      );
}
