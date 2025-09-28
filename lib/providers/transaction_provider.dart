import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  final List<Transaction> _transactions = [];

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  void addTransaction(Transaction tx) {
    _transactions.add(tx);
    notifyListeners();
  }

  void removeTransaction(int id) {
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }
}
