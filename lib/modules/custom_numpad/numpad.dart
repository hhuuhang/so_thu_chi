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
  final VoidCallback? onDone;
  final Color buttonColor;
  final Color textColor;
  final double buttonSize;
  final double fontSize;

  //THÊM MÀU KHI NHẤN
  final Color pressedColor;

  const CustomNumpad({
    super.key,
    required this.onKeyPress,
    required this.onErasePress,
    this.onDone,
    this.buttonColor = Colors.blueGrey,
    this.textColor = Colors.white,
    this.buttonSize = 80.0,
    this.fontSize = 30.0,
    Color? pressedColor,
  }) : pressedColor =
            pressedColor ?? Colors.black54;

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

  // Nút xoá
  Widget _buildEraseButton() {
    return Container(
      width: buttonSize,
      height: buttonSize,
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onErasePress,
        borderRadius: BorderRadius.circular(buttonSize / 2),
        child: Icon(
          Icons.backspace_outlined,
          color: textColor,
          size: fontSize,
        ),
      ),
    );
  }

  // Nút "Hoàn thành" — pill button canh phải (cột số 3)
  Widget _buildDoneButton(BuildContext context) {
    final callback = onDone ?? () => Navigator.of(context).pop();
    return SizedBox(
      width: buttonSize + 16, // cùng vùng chiếm chỗ với nút số
      height: 40,
      child: GestureDetector(
        onTap: callback,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          alignment: Alignment.center,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.keyboard_hide_rounded,
                color: Color(0xFF636366),
                size: 16,
              ),
              SizedBox(width: 5),
              Text(
                'Xong',
                style: TextStyle(
                  color: Color(0xFFAEAEB2),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
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
          // Hàng trên: nút "Xong" canh phải (vị trí cột số 3)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(width: buttonSize + 16),
              SizedBox(width: buttonSize + 16),
              _buildDoneButton(context),
            ],
          ),
          const SizedBox(height: 4),
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
