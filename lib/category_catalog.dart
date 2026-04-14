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

const Map<String, IconData> incomeCategories = {
  'Lương': Icons.attach_money,
  'Thưởng': Icons.star,
  'Tặng': Icons.card_giftcard,
  'Mượn': Icons.handshake,
  'Khác': Icons.more_horiz,
};

Map<String, IconData> categoriesForType(String type) {
  return type == 'income' ? incomeCategories : expenseCategories;
}

IconData iconForCategory(String category, String type) {
  return categoriesForType(type)[category] ?? Icons.more_horiz;
}
