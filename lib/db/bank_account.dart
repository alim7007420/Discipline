import 'package:isar/isar.dart';

part 'bank_account.g.dart';

@collection
class BankAccount {
  Id id = Isar.autoIncrement;
  
  late String accountName; // مثل بانک ملی، پاسارگاد، کیف پول
  double balance = 0.0;

  BankAccount({required this.accountName, this.balance = 0.0});
}
