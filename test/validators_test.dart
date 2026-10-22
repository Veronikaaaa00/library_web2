import 'package:flutter_test/flutter_test.dart';
import 'package:library_web/validation/validators.dart';

void main() {
  test('email и isbn', () {
    expect(Validators.email(null), isNotNull);
    expect(Validators.email('bad'), isNotNull);
    expect(Validators.email('a@b.ru'), isNull);
    expect(Validators.isbn('9785170901231'), isNull);
    expect(Validators.isbn('123'), isNotNull);
  });

  test('положительные числа', () {
    expect(Validators.positiveInt('0', label: 'x'), isNotNull);
    expect(Validators.positiveInt('3', label: 'x'), isNull);
    expect(Validators.nonNegativeInt('0', label: 'x'), isNull);
  });
}
