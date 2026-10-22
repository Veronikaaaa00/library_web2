class RelatedRecordsException implements Exception {
  RelatedRecordsException(this.count, {this.message});

  final int count;
  final String? message;

  @override
  String toString() =>
      message ?? 'Нельзя удалить: есть связанные записи ($count).';
}
