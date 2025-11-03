// screens/input_screen/input_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Thêm Provider
import 'package:intl/intl.dart';

import '../../constants.dart' show TransactionType;
import '../../modules/custom_numpad/numpad.dart';
import 'input_controller.dart'; // Import Controller

class InputScreen extends StatelessWidget {
  const InputScreen({super.key});

  // HÀM HIỂN THỊ BOTTOM SHEET (Không thể nằm trong Controller do cần BuildContext)
  void _showCustomNumpadSheet(BuildContext context, InputController controller) {
    final baseColor = controller.currentType == TransactionType.expense ? Colors.red.shade400 : Colors.green.shade400;
    
    final calculatedPressedColor = Color.fromARGB(
      baseColor.alpha, 
      (baseColor.red - 20).clamp(0, 255),
      (baseColor.green - 20).clamp(0, 255),
      (baseColor.blue - 20).clamp(0, 255),
    );
    
    // Tạo FocusNode cục bộ để xử lý focus
    final FocusNode amountFocusNode = FocusNode();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return CustomNumpad(
          onKeyPress: controller.handleKeyPress, // Gọi hàm từ Controller
          onErasePress: controller.handleErasePress, // Gọi hàm từ Controller
          buttonColor: baseColor,
          pressedColor: calculatedPressedColor,
          textColor: Colors.white,
          buttonSize: 70.0,
          fontSize: 28.0,
        );
      },
    ).whenComplete(() {
      // Đảm bảo focus được xóa khi sheet đóng
      amountFocusNode.unfocus();
    });
  }

  // Widget Tab Thu/Chi
  Widget _buildTypeTab(BuildContext context, InputController controller, TransactionType type, String label) {
    bool isSelected = controller.currentType == type;
    return GestureDetector(
      onTap: () => controller.setCurrentType(type), // Gọi setter từ Controller
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
  Widget _buildCategoryGrid(BuildContext context, InputController controller) {
    final Map<String, IconData> categories = controller.currentCategories; // Lấy categories từ Controller
    final Color primaryColor = controller.currentType == TransactionType.expense ? Colors.red : Colors.green;
    final Color darkBackgroundColor = Colors.grey.shade900;
    
    int rowCount = (categories.length / 3).ceil();
    double gridHeight = rowCount * 1.2 * 100;
    
    return SizedBox(
      height: gridHeight, 
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          String categoryName = categories.keys.elementAt(index);
          IconData icon = categories.values.elementAt(index);
          
          bool isSelected = controller.selectedCategory == categoryName; // So sánh với state trong Controller
          
          return GestureDetector(
            onTap: () => controller.setSelectedCategory(categoryName), // Gọi hàm từ Controller
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
              )
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // SỬ DỤNG Consumer ĐỂ LẮNG NGHE VÀ TRUY CẬP LOGIC
    return Consumer<InputController>(
      builder: (context, controller, child) {
        final bool isExpense = controller.currentType == TransactionType.expense;
        final Color primaryColor = isExpense ? Colors.red : Colors.green;
        
        // Thiết lập FocusNode cục bộ cho TextField Amount
        final FocusNode amountFocusNode = FocusNode();
        // Lắng nghe focus changes và hiển thị numpad
        amountFocusNode.addListener(() {
          if (amountFocusNode.hasFocus) {
            FocusManager.instance.primaryFocus?.unfocus();
            _showCustomNumpadSheet(context, controller);
          }
        });

        // Áp dụng Dark Theme cục bộ
        return Theme(
          data: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.grey.shade900,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey.shade900,
              elevation: 0,
              foregroundColor: Colors.white,
            ),
            inputDecorationTheme: InputDecorationTheme(
              labelStyle: const TextStyle(color: Colors.grey),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
              hintStyle: const TextStyle(color: Colors.grey),
            ),
          ),
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 60,
              automaticallyImplyLeading: false,
              title: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  // border: Border.all(color: Colors.white),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildTypeTab(context, controller, TransactionType.expense, 'Tiền chi')),
                      const SizedBox(width: 10,),
                    Expanded(
                      child: _buildTypeTab(context, controller, TransactionType.income, 'Tiền thu')),
                  ],
                ),
              ),
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit, color: Colors.white)),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  // PHẦN CHỌN VÀ ĐIỀU HƯỚNG NGÀY THÁNG
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ngày', style: TextStyle(color: Colors.white, fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 16),
                        color: Colors.white,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => controller.navigateDate(-1), // Gọi Controller
                      ),
                      GestureDetector(
                        onTap: () => controller.selectDate(context), // Gọi Controller
                        child: Text(
                          // ⚠️ Lấy date từ Controller
                          '${DateFormat('dd/MM/yyyy').format(controller.date)} (${DateFormat('E', 'vi_VN').format(controller.date)})',
                          style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        color: Colors.white,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => controller.navigateDate(1), // Gọi Controller
                      ),
                      const SizedBox(width: 8), 
                    ],
                  ),
                ),
              ),
            ),
            
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  
                  // TRƯỜNG GHI CHÚ
                  TextField(
                    controller: controller.titleController, // Dùng Controller
                    decoration: const InputDecoration(labelText: 'Ghi chú', hintText: 'Chưa nhập vào'),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 10),

                  // TRƯỜNG SỐ TIỀN
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.amountController, // Dùng Controller
                          focusNode: amountFocusNode, // Dùng FocusNode cục bộ
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
                  
                  const Text('Danh mục', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  
                  // PHẦN DANH MỤC (GRIDVIEW)
                  _buildCategoryGrid(context, controller), // Truyền Controller
                  
                  const SizedBox(height: 20),
                  
                  // Nút Hoàn thành/Lưu
                  Center(
                    child: TextButton(
                      onPressed: () => controller.addTransaction(context), // Gọi hàm từ Controller
                      child: const Text('Hoàn thành', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}