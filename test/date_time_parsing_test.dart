import 'package:flutter_test/flutter_test.dart';
import 'package:university_news_app/app/config.dart';

void main() {
  test('parseDateTimeLocal preserves instant for ISO8601 Z', () {
    const iso = '2026-02-18T02:14:55.769Z';
    final utc = DateTime.parse(iso);
    final local = AppConfig.parseDateTimeLocal(iso);

    expect(local.toUtc(), utc);
    expect(local.isUtc, isFalse);
  });

  test('tryParseDateTimeLocal supports Mongo $date wrapper', () {
    const iso = '2026-02-18T02:14:55.769Z';
    final utc = DateTime.parse(iso);
    final local = AppConfig.tryParseDateTimeLocal({r'$date': iso});

    expect(local, isNotNull);
    expect(local!.toUtc(), utc);
  });
}

