import '../utils/json_utils.dart';

class Publisher {
  final int id;
  final String name;
  final String country;
  final DateTime? deletedAt;

  const Publisher({
    required this.id,
    required this.name,
    required this.country,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Publisher copyWith({
    String? name,
    String? country,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Publisher(
      id: id,
      name: name ?? this.name,
      country: country ?? this.country,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'country': country,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Publisher.fromJson(Map<String, dynamic> json) => Publisher(
        id: asInt(json['id']),
        name: asString(json['name']),
        country: asString(json['country']),
        deletedAt: asDateTime(json['deletedAt']),
      );
}
