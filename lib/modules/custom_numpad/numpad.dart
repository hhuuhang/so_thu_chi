import 'package:flutter/material.dart';

// Định nghĩa kiểu hàm callback khi một phím được bấm
typedef NumpadCallback = void Function(String value);

class _NumpadButton extends StatefulWidget {
  final String value;
  final NumpadCallback onPressed;
  final double size;
  final double fontSize;
  final Color buttonColor;
  final Color pressedColor; 
  final Color textColor;

  const _NumpadButton({
    required this.value,
    required this.onPressed,
    required this.size,
    required this.fontSize,
    required this.buttonColor,
    required this.pressedColor,
    required this.textColor,
  });

  @override
  State<_NumpadButton> createState() => _NumpadButtonState();
}

class _NumpadButtonState extends State<_NumpadButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = _isPressed ? widget.pressedColor : widget.buttonColor;

    return Container(
      width: widget.size,
      height: widget.size,
      margin: const EdgeInsets.all(8.0),
      // Sử dụng GestureDetector để bắt sự kiện chạm
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed(widget.value); // Gọi callback khi nhả phím
        },
        onTapCancel: () => setState(() => _isPressed = false),
        onLongPressUp: () => setState(() => _isPressed = false),
        // Dùng AnimatedContainer để chuyển màu mượt mà
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * 0.15).round()),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            widget.value,
            style: TextStyle(
              fontSize: widget.fontSize,
              color: widget.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// WIDGET CUSTOM NUMPAD (Stateless)
// ----------------------------------------------------
class CustomNumpad extends StatelessWidget {
  final NumpadCallback onKeyPress;
  final VoidCallback onErasePress;
  final Color buttonColor;
  final Color textColor;
  final double buttonSize;
  final double fontSize;

   // Tùy chọn: Widget cho phím đặc biệt (ví dụ: dấu chấm, enter)
  // final Widget? specialButton;
  // final String specialValue;
  
  //THÊM MÀU KHI NHẤN
  final Color pressedColor;

  const CustomNumpad({
    super.key,
    required this.onKeyPress,
    required this.onErasePress,
    this.buttonColor = Colors.blueGrey,
    this.textColor = Colors.white,
    this.buttonSize = 80.0,
    this.fontSize = 30.0,
    // this.specialValue = '.',
    Color? pressedColor,
  }) : pressedColor = pressedColor ?? Colors.black54; // Gán màu nhấn tĩnh hoặc mặc định

  // Widget riêng để tạo một nút bấm số/đặc biệt
  Widget _buildButton(String value) {
    return _NumpadButton(
      value: value,
      onPressed: onKeyPress,
      size: buttonSize,
      fontSize: fontSize,
      buttonColor: buttonColor,
      pressedColor: pressedColor,
      textColor: textColor,
    );
  }

  // Widget riêng để tạo nút xoá (Back button) - Sử dụng InkWell cho hiệu ứng gợn sóng mặc định
  Widget _buildEraseButton() {
    return Container(
      width: buttonSize,
      height: buttonSize,
      margin: const EdgeInsets.all(8.0),
      child: InkWell( // Sử dụng InkWell vì nó đã có hiệu ứng nhấn tích hợp
        onTap: onErasePress,
        borderRadius: BorderRadius.circular(buttonSize / 2),
        child: Icon(
          Icons.backspace_outlined,
          color: buttonColor, // Sử dụng màu nút bấm cho Icon
          size: fontSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Hàng 1: 1, 2, 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildButton('1'),
              _buildButton('2'),
              _buildButton('3'),
            ],
          ),
          // Hàng 2: 4, 5, 6
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildButton('4'),
              _buildButton('5'),
              _buildButton('6'),
            ],
          ),
          // Hàng 3: 7, 8, 9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildButton('7'),
              _buildButton('8'),
              _buildButton('9'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildButton('000'),  
              _buildButton('0'),
              // Phím xoá
              _buildEraseButton(),
            ],
          ),
          // Hàng 4: Phím đặc biệt, 0, Phím xoá
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: <Widget>[
          //     _buildButton(specialValue), // Phím thập phân
          //     _buildButton('0'),
          //     _buildEraseButton(), // Phím xoá
          //   ],
          // ),
        ],
      ),
    );
  }
}