import 'package:flutter_test/flutter_test.dart';
import 'package:saprima_kasir/domain/money.dart';

void main() {
  test('fixture tunai 2 × 20.000 − 2.000 = 38.000', () {
    expect(lineTotal(20000, 2000), 40000);
    final total = netTotal([40000], 2000);
    expect(total, 38000);
    expect(50000 - total, 12000);
  });
  test('pecahan dihitung integer dan half-up sekali per baris', () {
    expect(parseQuantity('1,250'), 1250);
    expect(lineTotal(15001, parseQuantity('0,500')), 7501);
    expect(lineTotal(1, 499), 0);
    expect(lineTotal(1, 500), 1);
    expect(quantityText(1250), '1,25');
    expect(quantityText(1), '0,001');
  });
  test('uang tidak menerima float, negatif, pemisah ambigu, overflow', () {
    for (final s in [
      '1.000',
      '1,50',
      '-1',
      'NaN',
      '1e6',
      '99999999999999',
      '',
    ]) {
      expect(() => parseRupiah(s), throwsA(isA<PosError>()));
    }
    expect(parseRupiah('50000'), 50000);
    expect(() => netTotal([1000], 1001), throwsA(isA<PosError>()));
    expect(() => netTotal([1000], -1), throwsA(isA<PosError>()));
    expect(() => lineTotal(maxPrice, maxQuantity), throwsA(isA<PosError>()));
  });
  test('jumlah tidak menerima nol, negatif, presisi berlebih', () {
    for (final s in ['0', '-1', '0,0001', '1.000,5', '1e2', '1000001']) {
      expect(() => parseQuantity(s), throwsA(isA<PosError>()));
    }
    expect(parseQuantity('0', allowZero: true), 0);
  });
  test('IDR dan waktu Jakarta eksplisit', () {
    expect(rupiah(1234567), 'Rp1.234.567');
    expect(rupiah(0), 'Rp0');
    expect(rupiah(-15000), '-Rp15.000');
    expect(localDate('2026-12-31T18:05:00Z'), '01/01/2027 • 01.05 WIB');
  });
}
