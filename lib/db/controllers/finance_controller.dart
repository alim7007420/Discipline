import 'package:isar/isar.dart';
import '../database_service.dart';
import '../bank_account.dart';
import '../transaction_record.dart';
import '../enums.dart';

class FinanceController {
  final Isar _db = DatabaseService().db;

  /// اضافه کردن تراکنش و به‌روزرسانی خودکار موجودی حساب بانکی
  Future<void> addTransaction(TransactionRecord tx, int accountId) async {
    final account = await _db.bankAccounts.get(accountId);
    if (account == null) return;

    await _db.writeTxn(() async {
      await _db.transactionRecords.put(tx);

      if (tx.type == TransactionType.income) {
        account.balance += tx.amount;
      } else {
        account.balance -= tx.amount;
      }

      await _db.bankAccounts.put(account);
    });
  }
}
