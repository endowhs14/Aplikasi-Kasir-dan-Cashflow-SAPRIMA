/// IDR uses whole Rupiah; quantities use thousandths. Never parse money as double.
const maxMoney = 1000000000000;
const maxPrice = 1000000000;
const maxQuantity = 1000000000;

class PosError implements Exception {
  const PosError(this.message);
  final String message;
  @override
  String toString() => message;
}

int parseRupiah(String value, {int max = maxMoney}) {
  final text = value.trim();
  if (!RegExp(r'^\d{1,13}$').hasMatch(text)) {
    throw const PosError('Masukkan Rupiah bulat tanpa titik atau koma.');
  }
  final amount = int.parse(text);
  if (amount > max) throw const PosError('Nominal terlalu besar.');
  return amount;
}

int parseQuantity(String value, {bool allowZero = false}) {
  final text = value.trim().replaceAll(',', '.');
  if (!RegExp(r'^\d{1,7}(\.\d{1,3})?$').hasMatch(text)) {
    throw const PosError('Jumlah maksimal 3 angka desimal, contoh 1,250.');
  }
  final parts = text.split('.');
  final q =
      int.parse(parts[0]) * 1000 +
      (parts.length == 2 ? int.parse(parts[1].padRight(3, '0')) : 0);
  if (q > maxQuantity || q < (allowZero ? 0 : 1)) {
    throw const PosError('Jumlah di luar batas yang diperbolehkan.');
  }
  return q;
}

int lineTotal(int price, int quantity) {
  if (price < 0 ||
      price > maxPrice ||
      quantity <= 0 ||
      quantity > maxQuantity) {
    throw const PosError('Harga atau jumlah tidak valid.');
  }
  final result = (price * quantity + 500) ~/ 1000; // half-up, once per line
  if (result > maxMoney) throw const PosError('Total terlalu besar.');
  return result;
}

int netTotal(Iterable<int> amounts, int discount) {
  final gross = amounts.fold<int>(0, (a, b) => a + b);
  if (gross > maxMoney || discount < 0 || discount > gross) {
    throw const PosError('Diskon tidak boleh melebihi subtotal.');
  }
  return gross - discount;
}

String rupiah(int amount) {
  final digits = amount.abs().toString();
  final buffer = StringBuffer(amount < 0 ? '-Rp' : 'Rp');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

String quantityText(int quantity) {
  final sign = quantity < 0 ? '-' : '';
  final q = quantity.abs();
  final fraction = (q % 1000)
      .toString()
      .padLeft(3, '0')
      .replaceFirst(RegExp(r'0+$'), '');
  return '$sign${q ~/ 1000}${fraction.isEmpty ? '' : ',$fraction'}';
}

String localDate(String iso) {
  // This initial single-shop milestone uses Asia/Jakarta (UTC+7).
  final t = DateTime.parse(iso).toUtc().add(const Duration(hours: 7));
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(t.day)}/${two(t.month)}/${t.year} • ${two(t.hour)}.${two(t.minute)} WIB';
}
