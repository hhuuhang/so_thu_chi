import 'package:intl/intl.dart';

class Transaction {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final String type;
  final String category;

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type,
      'category': category,
    };
  }

  static Transaction fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      type: map['type'],
      category: map['category'],
    );
  }

  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String get formattedAmount {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }
}
