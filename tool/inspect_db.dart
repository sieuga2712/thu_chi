import 'package:sqlite3/sqlite3.dart';

void main(List<String> args) {
  final db = sqlite3.open(args[0]);
  final result = db.select(
    'SELECT id, account, amount, transaction_time, description, balance_after, fingerprint, created_at FROM transactions ORDER BY id',
  );
  for (final row in result) {
    print(row.toString());
  }
  db.close();
}
