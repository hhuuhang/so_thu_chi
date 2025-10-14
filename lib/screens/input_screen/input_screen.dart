import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'
    show StringTranslateExtension;
import '../../models/transaction.dart';
import '../../database/database_helper.dart';
import 'package:intl/intl.dart';
import '../../modules/custom_numpad/numpad.dart';
import '../../utils/number_utils.dart';

enum TransactionType {expense, income}
class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputPageStateState();
}

class _InputPageStateState extends State<InputScreen> {
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController =
      TextEditingController(text: '0');
  
  TransactionType _currentType = TransactionType.expense;
  String _selectedCategory = 'Ăn uống';
  DateTime date = DateTime.now();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  //FocusNode cho Số tiền (Kích hoạt Bottom Sheet)
  final FocusNode _amountFocusNode = FocusNode();
  //FocusNode cho Mô tả (Kích hoạt bàn phím mặc định)
  final FocusNode _titleFocusNode = FocusNode();

  //Danh mục
  final Map<String, IconData> expenseCategories = {
    'Ăn uống': Icons.restaurant,
    'Chi tiêu': Icons.clean_hands,
    'Mua sắm': Icons.shopping_bag,
    'Trả nợ': Icons.payments,
    'Phí giao lưu': Icons.wine_bar,
    'Y tế': Icons.medical_services,
    'phát triển bản t...': Icons.lightbulb,
    'Đầu tư': Icons.monetization_on,
    'Đi lại': Icons.train,
    'Giải trí': Icons.music_note,
    'Xăng xe': Icons.local_gas_station,
    'Tiền nhà': Icons.home,
  };


  @override
  void initState() {
    super.initState();
    _loadTransactions();
    //Lắng nghe focus cho "Số tiền"
    _amountFocusNode.addListener(_handleAmountFocusChange);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _amountFocusNode.removeListener(_handleAmountFocusChange);
    _amountFocusNode.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  // Chuyển đổi enum sang string để lưu DB
  String get _typeString => _currentType == TransactionType.income ? 'income' : 'expense';

  Future<void> _loadTransactions() async {
    List<Transaction> transactions = await _dbHelper.getTransactions();
    Map<String, Map<String, double>> chartData = {};
    for (var tx in transactions) {
      String dateKey = DateFormat('dd/MM/yyyy').format(tx.date);
      if (!chartData.containsKey(dateKey)) {
        chartData[dateKey] = {'income': 0.0, 'expense': 0.0};
      }
      if (tx.type == 'income') {
        chartData[dateKey]!['income'] =
            chartData[dateKey]!['income']! + tx.amount;
      } else {
        chartData[dateKey]!['expense'] =
            chartData[dateKey]!['expense']! + tx.amount;
      }
    }
  }

  void _handleAmountFocusChange() {
    // Chỉ xử lý khi Số tiền nhận focus
    if (_amountFocusNode.hasFocus) {
      // Ẩn bàn phím hệ thống (nếu nó đang hiện)
      FocusManager.instance.primaryFocus?.unfocus();

      // Hiển thị Bottom Sheet chứa bàn phím custom
      _showCustomNumpadSheet();
    }
  }

  void _showCustomNumpadSheet() {
    // Tự động đóng Bottom Sheet nếu màn hình bị dispose
    showModalBottomSheet(
      context: context,
      // Cho phép Bottom Sheet chiếm toàn bộ chiều rộng
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return CustomNumpad(
          onKeyPress: _handleKeyPress,
          onErasePress: _handleErasePress,
          buttonColor: Colors.indigo.shade400,
          textColor: Colors.white,
          buttonSize: 70.0,
          fontSize: 28.0,
        );
      },
      // Khi Bottom Sheet đóng, đảm bảo focus được xóa khỏi TextField
    ).whenComplete(() {
      if (_amountFocusNode.hasFocus) {
        _amountFocusNode.unfocus();
      }
    });
  }

  void _addTransaction() async {
    String title = _titleController.text;
    // SỬ DỤNG HÀM TỪ UTILS ĐỂ LẤY GIÁ TRỊ DOUBLE SẠCH
    double amount = parseToDouble(_amountController.text);

    if (title.isNotEmpty && amount > 0) {
      Transaction newTx = Transaction(
        title: title,
        amount: amount,
        date: date,
        type: _typeString,
      );
      await _dbHelper.insertTransaction(newTx);
      _loadTransactions();

      // Reset fields after adding transaction
      setState(() {
        _titleController.clear();
        _amountController.text = '0';
        _currentType = TransactionType.expense;
        _selectedCategory = 'Ăn uống';
        date = DateTime.now();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Giao dịch đã được thêm!')),
        );
      }
    }
  }

  // Hàm xử lý nhập phím (được truyền vào CustomNumpad)
  void _handleKeyPress(String value) {
    //Chuyển chuỗi định dạng hiện tại thành chuỗi thô
    String rawText = removeFormat(_amountController.text);

    //Logic cập nhật số tiền (trên chuỗi thô)
    if (value == '.') {
      if (rawText.contains('.')) return;
      if (rawText.isEmpty) rawText = '0';
    }

    setState(() {
      if (rawText == '0' && value != '.') {
        rawText = value;
      } else {
        rawText += value;
      }

      //SỬ DỤNG HÀM TỪ UTILS: Định dạng lại chuỗi thô và gán vào controller
      _amountController.text = formatAmount(rawText);
    });

    //Di chuyển con trỏ về cuối
    _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length));
  }

  // Hàm xử lý xoá phím (được truyền vào CustomNumpad)
  void _handleErasePress() {
    //Chuyển chuỗi định dạng hiện tại thành chuỗi thô
    String rawText = removeFormat(_amountController.text);

    setState(() {
      if (rawText.isNotEmpty) {
        String newRawText = rawText.substring(0, rawText.length - 1);

        if (newRawText.isEmpty) {
          _amountController.text = '0';
        } else {
          //SỬ DỤNG HÀM TỪ UTILS: Định dạng lại và gán vào controller
          _amountController.text = formatAmount(newRawText);
        }
      }
    });

    //Di chuyển con trỏ về cuối
    _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length));
  }

  void _deleteTransaction(int id) async {
    await _dbHelper.deleteTransaction(id);
    _loadTransactions();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giao dịch đã được xóa!')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(1997),
      lastDate: DateTime(2101),
      helpText: 'Chọn Ngày Giao Dịch', // Tiêu đề của DatePicker
      cancelText: 'Hủy',
      confirmText: 'Xác nhận',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    // Nếu người dùng chọn một ngày (không nhấn hủy)
    if (picked != null && picked != date) {
      setState(() {
        date = picked;
      });
    }
  }

   // Thêm hàm điều hướng ngày tháng
  void _navigateDate(int days) {
    setState(() {
      date = date.add(Duration(days: days));
    });
  }

  // --- WIDGET XÂY DỰNG GIAO DIỆN ---
  
  // Widget Tab Thu/Chi
  Widget _buildTypeTab(TransactionType type, String label) {
    bool isSelected = _currentType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentType = type;
          _amountController.text = '0'; // Reset số tiền khi đổi loại
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

   // Widget Danh mục
  Widget _buildCategoryGrid() {
    final Color primaryColor = _currentType == TransactionType.expense ? Colors.red : Colors.green;
    final Color darkBackgroundColor = Colors.grey.shade900;
    
    return GridView.builder(
      shrinkWrap: true, // Chiếm không gian cần thiết
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenseCategories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        String categoryName = expenseCategories.keys.elementAt(index);
        IconData icon = expenseCategories.values.elementAt(index);
        bool isSelected = _selectedCategory == categoryName;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = categoryName;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withAlpha((255 * 0.2).round()) : darkBackgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? primaryColor : Colors.grey.shade700,
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: isSelected ? primaryColor : Colors.white, size: 28),
                const SizedBox(height: 4),
                Text(
                  categoryName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? primaryColor : Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
     final bool isExpense = _currentType == TransactionType.expense;
     final Color primaryColor = isExpense ? Colors.red : Colors.green;
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          automaticallyImplyLeading: false,
          // ⚠️ TAB CHUYỂN ĐỔI THU/CHI
          title: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypeTab(TransactionType.expense, 'Tiền chi'),
                _buildTypeTab(TransactionType.income, 'Tiền thu'),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit, color: Colors.white),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              // ⚠️ PHẦN CHỌN VÀ ĐIỀU HƯỚNG NGÀY THÁNG
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ngày', style: TextStyle(color: Colors.white, fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 16),
                    color: Colors.white,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _navigateDate(-1),
                  ),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Text(
                      '${DateFormat('dd/MM/yyyy').format(date)} (${DateFormat('E', 'vi_VN').format(date)})',
                      style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    color: Colors.white,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _navigateDate(1),
                  ),
                  const SizedBox(width: 8), 
                ],
              ),
            ),
          ),
        ),
        
        body: SingleChildScrollView( // Bọc toàn bộ body bằng SingleChildScrollView
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              // TRƯỜNG GHI CHÚ
              TextField(
                controller: _titleController,
                focusNode: _titleFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú', 
                  hintText: 'Chưa nhập vào',
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 10),

              // TRƯỜNG SỐ TIỀN
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      focusNode: _amountFocusNode,
                      decoration: InputDecoration(
                        labelText: isExpense ? 'Tiền chi' : 'Tiền thu',
                        labelStyle: const TextStyle(color: Colors.grey, fontSize: 18),
                        suffixText: '₫',
                        suffixStyle: TextStyle(color: primaryColor, fontSize: 18),
                      ),
                      readOnly: true, 
                      showCursor: true, 
                      textAlign: TextAlign.left,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // TIÊU ĐỀ DANH MỤC
              const Text('Danh mục', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              // PHẦN DANH MỤC (GRIDVIEW)
              _buildCategoryGrid(),
              
              const SizedBox(height: 20),
              
              // Nút Hoàn thành/Lưu
              Center(
                child: TextButton(
                  onPressed: _addTransaction,
                  child: const Text('Hoàn thành', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              
              // Khoảng trống đệm cuối cùng (quan trọng cho cuộn)
              const SizedBox(height: 50),
            ],
          ),
        ),
      );
  }
}
