// Process-level crash fixture. This public key is TEST DATA, never used by the app.
import 'dart:convert';
import 'dart:io';

import 'package:saprima_kasir/data/store.dart';
import 'package:saprima_kasir/domain/models.dart';

const fixtureKey =
    '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
void check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

void main(List<String> args) {
  final dir = args[0], phase = args[1];
  final store = Store.open('$dir/crash.sqlite', fixtureKey, demo: false);
  if (phase == 'seed') {
    final p = store.saveProduct(
      name: 'Fixture crash',
      sku: 'CRASH',
      category: 'Uji',
      unit: 'buah',
      price: 20000,
      service: false,
      openingStock: 10000,
    );
    store.saveDraft('crash-sale', [CartLine(p, 2000)], '2000', '50000');
    File('$dir/request.json')
        .writeAsStringSync(jsonEncode([CartLine(p, 2000).toMap()]));
  } else if (phase == 'before_commit' ||
      phase == 'after_commit' ||
      phase == 'replay') {
    final lines =
        (jsonDecode(File('$dir/request.json').readAsStringSync()) as List)
            .map((l) => CartLine.fromMap(Map<String, Object?>.from(l as Map)))
            .toList();
    store.checkout(
      requestId: 'crash-sale',
      lines: lines,
      discount: 2000,
      cash: 50000,
      fault: (stage) {
        if (stage == phase) {
          stdout.writeln('Crash injected: $stage');
          exit(77);
        }
      },
    );
  } else {
    final committed = phase == 'verify_committed';
    for (final table in [
      'sales',
      'sale_items',
      'payments',
      'cash_entries',
      'outbox',
    ]) {
      check(
        store.db.select('SELECT count(*) AS n FROM $table').first['n'] ==
            (committed ? 1 : 0),
        'Wrong count: $table',
      );
    }
    final p = store.products().single;
    check(p.stock == (committed ? 8000 : 10000), 'Wrong stock');
    check(
      store.db
              .select('SELECT sum(delta) AS q FROM stock_movements')
              .first['q'] ==
          p.stock,
      'Ledger mismatch',
    );
    check((store.loadDraft() == null) == committed, 'Draft recovery mismatch');
    check(
      store.db.select('PRAGMA integrity_check').first.values.first == 'ok',
      'Integrity failed',
    );
    if (committed) {
      check(store.sale('crash-sale').total == 38000, 'Wrong amount');
    }
    stdout.writeln(
      'PASS $phase: sale/items/payment/cash/outbox/stock/draft/integrity',
    );
  }
  store.close();
}
