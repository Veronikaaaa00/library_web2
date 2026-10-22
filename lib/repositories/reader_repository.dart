import '../models/page_result.dart';
import '../models/reader.dart';
import '../models/reader_query.dart';

abstract interface class ReaderRepository {
  Future<PageResult<Reader>> find(ReaderQuery query);

  Future<List<Reader>> findAll({bool includeDeleted = false});

  Future<Reader?> findById(int id);

  Future<Reader> create(Reader reader);

  Future<Reader> update(Reader reader);

  Future<void> softDelete(int id);

  Future<void> hardDelete(int id);

  Future<void> restore(int id);

  Future<int> deleteMany(List<int> ids);

  Future<bool> isEmailTaken(String email, {int? excludeId});
}
