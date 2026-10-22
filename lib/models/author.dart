import '../utils/json_utils.dart';

class Author {
  final int id;
  final String firstName;
  final String lastName;
  final String country;
  final int birthYear;
  final String? bio;
  final DateTime? deletedAt;

  const Author({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.birthYear,
    this.bio,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  String get fullName => '$lastName $firstName';

  Author copyWith({
    String? firstName,
    String? lastName,
    String? country,
    int? birthYear,
    String? bio,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Author(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      country: country ?? this.country,
      birthYear: birthYear ?? this.birthYear,
      bio: bio ?? this.bio,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'country': country,
        'birthYear': birthYear,
        'bio': bio,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Author.fromJson(Map<String, dynamic> json) => Author(
        id: asInt(json['id']),
        firstName: asString(json['firstName']),
        lastName: asString(json['lastName']),
        country: asString(json['country']),
        birthYear: asInt(json['birthYear']),
        bio: json['bio'] == null ? null : asString(json['bio']),
        deletedAt: asDateTime(json['deletedAt']),
      );
}
