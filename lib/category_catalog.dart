import 'package:flutter/material.dart';

const Map<String, IconData> expenseCategories = {
  'Ăn uống': Icons.restaurant,
  'Chi tiêu': Icons.clean_hands,
  'Mua sắm': Icons.shopping_bag,
  'Trả nợ': Icons.payments,
  'Phí giao lưu': Icons.wine_bar,
  'Y tế': Icons.medical_services,
  'Phát triển bản thân': Icons.lightbulb,
  'Đầu tư': Icons.monetization_on,
  'Đi lại': Icons.train,
  'Giải trí': Icons.music_note,
  'Xăng xe': Icons.local_gas_station,
  'Tiền nhà': Icons.home,
  'Khác': Icons.more_horiz,
};

const Map<String, Color> expenseCategoryColors = {
  'Ăn uống': Colors.orange,
  'Chi tiêu': Colors.blue,
  'Mua sắm': Colors.pink,
  'Trả nợ': Colors.red,
  'Phí giao lưu': Colors.purple,
  'Y tế': Colors.teal,
  'Phát triển bản thân': Colors.orange,
  'Đầu tư': Colors.green,
  'Đi lại': Colors.indigo,
  'Giải trí': Colors.deepOrange,
  'Xăng xe': Colors.blueGrey,
  'Tiền nhà': Colors.brown,
  'Khác': Colors.grey,
};

const Map<String, IconData> incomeCategories = {
  'Lương': Icons.attach_money,
  'Thưởng': Icons.star,
  'Tặng': Icons.card_giftcard,
  'Mượn': Icons.handshake,
  'Khác': Icons.more_horiz,
};

const Map<String, Color> incomeCategoryColors = {
  'Lương': Colors.green,
  'Thưởng': Colors.orange,
  'Tặng': Colors.pink,
  'Mượn': Colors.blue,
  'Khác': Colors.grey,
};

Map<String, IconData> categoriesForType(String type) {
  return type == 'income' ? incomeCategories : expenseCategories;
}

IconData iconForCategory(String category, String type) {
  return categoriesForType(type)[category] ?? Icons.more_horiz;
}

Color colorForCategory(String category, String type, {bool isDark = true}) {
  final colorMap =
      type == 'income' ? incomeCategoryColors : expenseCategoryColors;
  final color = colorMap[category] ?? Colors.grey;

  if (isDark) {
    // In dark mode, we can use slightly lighter/vibrant versions
    if (color == Colors.amber) return Colors.amber.shade400;
    if (color == Colors.blueGrey) return Colors.blueGrey.shade300;
    return color;
  } else {
    // In light mode, we need more contrast
    if (color == Colors.amber) {
      return Colors.amber.shade800; // Amber is too light for white
    }
    if (color == Colors.orange) return Colors.orange.shade800;
    if (color == Colors.green) return Colors.green.shade700;
    if (color == Colors.teal) return Colors.teal.shade700;
    if (color == Colors.blue) return Colors.blue.shade700;
    if (color == Colors.pink) return Colors.pink.shade600;
    if (color == Colors.red) return Colors.red.shade700;
    if (color == Colors.purple) return Colors.purple.shade600;
    if (color == Colors.deepOrange) return Colors.deepOrange.shade700;
    if (color == Colors.indigo) return Colors.indigo.shade700;
    return color;
  }
}
