import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants.dart' show TransactionType;
import '../../category_catalog.dart' show colorForCategory;
import '../../modules/custom_numpad/numpad.dart';
import '../../theme/app_colors.dart';
import 'input_controller.dart';

class InputScreen extends StatelessWidget {
  const InputScreen({super.key});

  void _showCustomNumpadSheet(
      BuildContext context, InputController controller) {
    final colors = Theme.of(context).colorScheme;
    // Determine the primary color based on transaction type for subtle pressed effect
    final primaryColor = controller.currentType == TransactionType.expense
        ? Colors.red
        : Colors.green;

    // Professional theme colors for numpad
    final buttonColor = colors.numpadButtonBg;
    // When pressed, blend a little bit of the primary color with the button bg
    final pressedColor = Color.alphaBlend(
      primaryColor.withOpacity(0.3),
      colors.numpadButtonBg,
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.numpadBg,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return CustomNumpad(
          onKeyPress: controller.handleKeyPress,
          onErasePress: controller.handleErasePress,
          buttonColor: buttonColor,
          pressedColor: pressedColor,
          textColor: colors.numpadTextColor,
          buttonSize: 70,
          fontSize: 28,
        );
      },
    );
  }

  Widget _buildTypeTab(
    BuildContext context,
    InputController controller,
    TransactionType type,
    String label,
  ) {
    final colors = Theme.of(context).colorScheme;
    final isSelected = controller.currentType == type;

    return GestureDetector(
      onTap: () => controller.setCurrentType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.inputTabSelectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: colors.inputTabBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? colors.inputTabSelectedText
                : colors.inputTabUnselectedText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, InputController controller) {
    final colors = Theme.of(context).colorScheme;
    final categories = controller.currentCategories;

    final rowCount = (categories.length / 3).ceil();
    final gridHeight = rowCount * 1.1 * 100;

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
          final categoryName = categories.keys.elementAt(index);
          final icon = categories.values.elementAt(index);
          final isSelected = controller.selectedCategory == categoryName;
          final categoryColor = colorForCategory(
              categoryName,
              controller.currentType == TransactionType.expense
                  ? 'expense'
                  : 'income',
              isDark: colors.brightness == Brightness.dark);

          return GestureDetector(
            onTap: () => controller.setSelectedCategory(categoryName),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? categoryColor.withOpacity(0.2)
                    : colors.inputCategoryBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? categoryColor : colors.inputCategoryBorder,
                  width: isSelected ? 2 : 1,
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? categoryColor
                        : categoryColor.withOpacity(0.7),
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    categoryName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? categoryColor
                          : categoryColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Consumer<InputController>(
      builder: (context, controller, child) {
        final isExpense = controller.currentType == TransactionType.expense;
        final primaryColor = isExpense ? Colors.red : Colors.green;

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 60,
            automaticallyImplyLeading: false,
            leading: controller.isEditMode
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      controller.resetToCreateMode();
                      Navigator.of(context).maybePop();
                    },
                  )
                : null,
            title: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildTypeTab(
                      context,
                      controller,
                      TransactionType.expense,
                      'Tiền chi',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTypeTab(
                      context,
                      controller,
                      TransactionType.income,
                      'Tiền thu',
                    ),
                  ),
                ],
              ),
            ),
            actions: const [],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ngày',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                        color: colors.textPrimary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => controller.navigateDate(-1),
                    ),
                    GestureDetector(
                      onTap: () => controller.selectDate(context),
                      child: Text(
                        '${DateFormat('dd/MM/yyyy').format(controller.date)} (${DateFormat('E', 'vi_VN').format(controller.date)})',
                        style: TextStyle(
                          fontSize: 18,
                          color: colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: colors.textPrimary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => controller.navigateDate(1),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                TextField(
                  controller: controller.titleController,
                  decoration: InputDecoration(
                    labelText: 'Ghi chú',
                    hintText: 'Chưa nhập vào',
                    labelStyle: TextStyle(color: colors.textTertiary),
                    hintStyle: TextStyle(color: colors.textTertiary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colors.subtleDivider),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  style: TextStyle(color: colors.textPrimary),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.amountController,
                        decoration: InputDecoration(
                          labelText: isExpense ? 'Tiền chi' : 'Tiền thu',
                          labelStyle: TextStyle(
                            color: colors.textTertiary,
                            fontSize: 18,
                          ),
                          suffixText: '₫',
                          suffixStyle:
                              TextStyle(color: primaryColor, fontSize: 18),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: colors.subtleDivider),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                          ),
                        ),
                        readOnly: true,
                        showCursor: true,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: primaryColor,
                        ),
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          _showCustomNumpadSheet(context, controller);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Danh mục',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildCategoryGrid(context, controller),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      minimumSize: WidgetStateProperty.all(
                        const Size(200, 50),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      backgroundColor:
                          WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.pressed)) {
                          return colors.confirmButtonPressedBg;
                        }
                        return colors.confirmButtonBg;
                      }),
                      foregroundColor:
                          WidgetStateProperty.all(colors.confirmButtonText),
                      elevation: WidgetStateProperty.all(4),
                      shadowColor: WidgetStateProperty.all(
                        colors.confirmButtonBg.withOpacity(0.4),
                      ),
                    ),
                    onPressed: () => controller.addTransaction(context),
                    child: Text(
                      controller.isEditMode ? 'Cập nhật' : 'Hoàn thành',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }
}
