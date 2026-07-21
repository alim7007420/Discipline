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
        .findAll();

    setState(() {
      _accounts = accounts;
      _transactions = transactions;
      if (accounts.isNotEmpty && _selectedAccountId == null) {
        _selectedAccountId = accounts.first.id;
      }
    });
  }

  Future<void> _createNewAccount() async {
    if (_accountNameController.text.trim().isEmpty) return;
    final double initialBalance = double.tryParse(_balanceController.text) ?? 0.0;

    final newAccount = BankAccount(
      accountName: _accountNameController.text.trim(),
      balance: initialBalance,
    );

    await _db.writeTxn(() async {
      await _db.bankAccounts.put(newAccount);
    });

    _accountNameController.clear();
    _balanceController.clear();
    _loadFinanceData();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _submitTransaction() async {
    if (_amountController.text.trim().isEmpty || _selectedAccountId == null) return;
    final double amount = double.tryParse(_amountController.text) ?? 0.0;

    final now = DateTime.now();
    final todayKey = int.parse(
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}");

    final transaction = TransactionRecord(
      amount: amount,
      type: _selectedTxType,
      category: _selectedTxType == TransactionType.income ? 'درآمد عمومی' : 'هزینه عمومی',
      description: _descController.text.trim(),
      dateKey: todayKey,
    );

    await _financeController.addTransaction(transaction, _selectedAccountId!);

    _amountController.clear();
    _descController.clear();
    _loadFinanceData();
    if (mounted) Navigator.pop(context);
  }

  void _showAddTxBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20, left: 16, right: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: _selectedAccountId,
                    decoration: const InputDecoration(labelText: 'انتخاب حساب'),
                    items: _accounts.map((acc) {
                      return DropdownMenuItem<int>(
                        value: acc.id,
                        child: Text('${acc.accountName} (${acc.balance} تومان)'),
                      );
                    }).toList(),
                    onChanged: (val) => setModalState(() => _selectedAccountId = val),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ChoiceChip(
                        label: const Text('هزینه'),
                        selected: _selectedTxType == TransactionType.expense,
                        onSelected: (val) => setModalState(() => _selectedTxType = TransactionType.expense),
                      ),
                      ChoiceChip(
                        label: const Text('درآمد'),
                        selected: _selectedTxType == TransactionType.income,
                        onSelected: (val) => setModalState(() => _selectedTxType = TransactionType.income),
                      ),
                    ],
                  ),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'مبلغ'),
                  ),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'توضیحات'),
                  ),
                  ElevatedButton(
                    onPressed: _submitTransaction,
                    child: const Text('ثبت'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('امور مالی')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: _accountNameController, decoration: const InputDecoration(labelText: 'نام حساب')),
                      TextField(controller: _balanceController, decoration: const InputDecoration(labelText: 'موجودی')),
                      ElevatedButton(onPressed: _createNewAccount, child: const Text('ثبت حساب')),
                    ],
                  ),
                ),
              );
            },
            child: const Text('افزودن حساب جدید'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final tx = _transactions[index];
                return ListTile(
                  title: Text(tx.category),
                  subtitle: Text('${tx.amount} تومان'),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTxBottomSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
