// numpad_button.dart
import 'package:flutter/material.dart';

class NumpadButton extends StatefulWidget {
  final String value;
  final double size;
  final double fontSize;
  final Color buttonColor;
  final Color pressedColor; // Màu khi nhấn
  final Color textColor;
  final void Function(String) onPressed;

  const NumpadButton({
    super.key,
    required this.value,
    required this.size,
    required this.fontSize,
    required this.buttonColor,
    required this.pressedColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  State<NumpadButton> createState() => _NumpadButtonState();
}

class _NumpadButtonState extends State<NumpadButton> {
  // Biến trạng thái để theo dõi xem nút có đang được nhấn hay không
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Chọn màu nền dựa trên trạng thái nhấn
    final color = _isPressed ? widget.pressedColor : widget.buttonColor;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      // Sử dụng GestureDetector để bắt sự kiện chạm và nhả
      child: GestureDetector(
        // Sự kiện khi bắt đầu chạm (nhấn xuống)
        onTapDown: (_) {
          setState(() {
            _isPressed = true;
          });
        },
        // Sự kiện khi kết thúc chạm (nhả ra)
        onTapUp: (_) {
          setState(() {
            _isPressed = false;
          });
          widget.onPressed(widget.value); // Gọi hàm xử lý sau khi nhả
        },
        // Sự kiện khi chạm bị hủy (ví dụ: cuộn ra khỏi nút)
        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: color, // Màu thay đổi
            shape: BoxShape.circle,
            boxShadow: _isPressed
                ? null // Bỏ shadow khi nhấn để tạo cảm giác chìm xuống
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          alignment: Alignment.center,
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
