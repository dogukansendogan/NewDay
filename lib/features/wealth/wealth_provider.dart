import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// İşlem Modeli
class Transaction {
  final String id;
  final String title;
  final double amount;
  final bool isExpense; // Harcama mı?
  final DateTime date;
  final String category; // Yemek, Teknoloji, Yatırım vb.

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.date,
    required this.category,
  });
}

// Durum
class WealthState {
  final List<Transaction> transactions;
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;

  WealthState({
    required this.transactions,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
  });
}

class WealthNotifier extends Notifier<WealthState> {
  @override
  WealthState build() {
    // Başlangıç verileri (Boş hissettirmesin diye)
    return WealthState(
      transactions: [
        Transaction(id: const Uuid().v4(), title: "Freelance Proje", amount: 1500.0, isExpense: false, date: DateTime.now().subtract(const Duration(days: 1)), category: "İş"),
        Transaction(id: const Uuid().v4(), title: "Sunucu Kirası", amount: 120.0, isExpense: true, date: DateTime.now().subtract(const Duration(days: 2)), category: "Tech"),
        Transaction(id: const Uuid().v4(), title: "Kahve & Mola", amount: 45.0, isExpense: true, date: DateTime.now(), category: "Yaşam"),
      ],
      totalBalance: 1335.0,
      totalIncome: 1500.0,
      totalExpense: 165.0,
    );
  }

  void addTransaction(String title, double amount, bool isExpense, String category) {
    final newTrans = Transaction(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      isExpense: isExpense,
      date: DateTime.now(),
      category: category,
    );

    final newTransactions = [newTrans, ...state.transactions];
    _calculateTotals(newTransactions);
  }

  void deleteTransaction(String id) {
    final newTransactions = state.transactions.where((t) => t.id != id).toList();
    _calculateTotals(newTransactions);
  }

  void _calculateTotals(List<Transaction> transactions) {
    double income = 0;
    double expense = 0;

    for (var t in transactions) {
      if (t.isExpense) {
        expense += t.amount;
      } else {
        income += t.amount;
      }
    }

    state = WealthState(
      transactions: transactions,
      totalIncome: income,
      totalExpense: expense,
      totalBalance: income - expense,
    );
  }
}

final wealthProvider = NotifierProvider<WealthNotifier, WealthState>(() => WealthNotifier());