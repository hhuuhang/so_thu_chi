import 'package:intl/intl.dart';

class Transaction {
  const Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
  });

  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final String type;
  final String category;

  static const fallbackCategory = 'Khác';

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
    final rawCategory = map['category'] as String?;

    return Transaction(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      date: DateTime.parse(map['date'] as String),
      type: map['type'] as String? ?? 'expense',
      category: rawCategory == null || rawCategory.trim().isEmpty
          ? fallbackCategory
          : rawCategory,
    );
  }

  Transaction copyWith({
    int? id,
    String? title,
    double? amount,
    DateTime? date,
    String? type,
    String? category,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
    );
  }

  String get formattedDate => DateFormat('dd/MM/yyyy').format(date);

  String get formattedAmount {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }
}
