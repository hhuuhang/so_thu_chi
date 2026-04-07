import 'package:intl/intl.dart';

// Format cho tiền tệ (sử dụng dấu chấm làm dấu phân cách hàng nghìn)
// Locale 'vi_VN' đảm bảo dấu chấm là phân cách nghìn và dấu phẩy là phân cách thập phân
final NumberFormat _numberFormatter = NumberFormat.decimalPattern('vi_VN');

/// Chuyển chuỗi số thô sang chuỗi có dấu phân cách (ví dụ: "1000000" -> "1.000.000")
String formatAmount(String rawAmount) {
  // 1. Loại bỏ tất cả các dấu phân cách cũ (dấu chấm)
  String cleanString = rawAmount.replaceAll('.', '');

  // 2. Tách phần nguyên và phần thập phân (sử dụng dấu chấm '.' cho thập phân)
  String integerPart = cleanString;
  String decimalPart = '';

  if (cleanString.contains('.')) {
    List<String> parts = cleanString.split('.');
    integerPart = parts[0];
    decimalPart = parts.length > 1 ? parts[1] : '';
  }

  // 3. Chuyển phần nguyên sang số để định dạng
  int? value = int.tryParse(integerPart);

  if (value == null) return rawAmount;

  // 4. Định dạng phần nguyên (ví dụ: 1000000 -> 1.000.000)
  String formattedInteger = _numberFormatter.format(value);

  // 5. Kết hợp lại với phần thập phân (dùng dấu chấm '.' như bàn phím custom)
  if (rawAmount.contains('.')) {
    return '$formattedInteger.$decimalPart';
  }

  return formattedInteger;
}

/// Chuyển chuỗi định dạng (ví dụ: "1.000.000") về chuỗi số thô (ví dụ: "1000000")
String removeFormat(String formattedAmount) {
  // Xóa tất cả các dấu chấm (phân cách nghìn)
  return formattedAmount.replaceAll('.', '');
}

// Hàm này dùng để lấy giá trị double sạch sẽ để tính toán hoặc lưu DB
double parseToDouble(String formattedAmount) {
  String cleanString =
      formattedAmount.replaceAll('.', ''); // Xóa dấu phân cách nghìn
  return double.tryParse(cleanString) ?? 0.0;
}
