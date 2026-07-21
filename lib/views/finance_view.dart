import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../db/database_service.dart';
import '../db/bank_account.dart';
import '../db/transaction_record.dart';
import '../db/enums.dart';
import '../db/controllers/finance_controller.dart';

class FinanceView extends StatefulWidget {
  const FinanceView({super.key});

  @override
  State<FinanceView> createState() => _FinanceViewState();
}

class _FinanceViewState extends State<FinanceView> {
  final Isar _db = DatabaseService().db;
  final FinanceController _financeController = FinanceController();

  List<BankAccount> _accounts = [];
  List<TransactionRecord> _transactions = [];

  final _accountNameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  int? _selectedAccountId;
  TransactionType _selectedTxType = TransactionType.expense;

  @override
  void initState() {
    super.initState();
    _loadFinanceData();
  }

  Future<void> _loadFinanceData() async {
    final accounts = await _db.bankAccounts.where().findAll();
    final transactions = await _db.transactionRecords
        .where()
        .sortByDateKeyDesc()
        .limit(10)
      
