import 'package:flutter/material.dart';

// Định nghĩa kiểu hàm callback khi một phím được bấm
typedef NumpadCallback = void Function(String value);

class CustomNumpad extends StatelessWidget {
  final NumpadCallback onKeyPress;
  final VoidCallback onErasePress;
  final Color buttonColor;
  final Color textColor;
  final double buttonSize;
  final double fontSize;
  
  // Tùy chọn: Widget cho phím đặc biệt (ví dụ: dấu chấm, enter)
  final Widget? specialButton;
  final String specialValue;

  const CustomNumpad({
    super.key,
    required this.onKeyPress,
    required this.onErasePress,
    this.buttonColor = Colors.blueGrey,
    this.textColor = Colors.white,
    this.buttonSize = 80.0,
    this.fontSize = 30.0,
    this.specialButton,
    this.specialValue = '.', // Giá trị mặc định cho phím đặc biệt
  });

  // Widget riêng để tạo một nút bấm số
  Widget _buildButton(String value, VoidCallback onPressed) {
    return Container(
      width: buttonSize,
      height: buttonSize,
      margin: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Widget riêng để tạo nút xoá (Back button)
  Widget _buildEraseButton() {
    return Container(
      width: buttonSize,
      height: buttonSize,
      margin: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onErasePress,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Màu nền trong suốt
          shadowColor: Colors.transparent,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
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
              _buildButton('1', () => onKeyPress('1')),
              _buildButton('2', () => onKeyPress('2')),
              _buildButton('3', () => onKeyPress('3')),
            ],
          ),
          // Hàng 2: 4, 5, 6
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildButton('4', () => onKeyPress('4')),
              _buildButton('5', () => onKeyPress('5')),
              _buildButton('6', () => onKeyPress('6')),
            ],
          ),
          // Hàng 3: 7, 8, 9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildButton('7', () => onKeyPress('7')),
              _buildButton('8', () => onKeyPress('8')),
              _buildButton('9', () => onKeyPress('9')),
            ],
          ),
          // Hàng 4: Phím đặc biệt, 0, Phím xoá
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // Phím đặc biệt (ví dụ: dấu '.')
              if (specialButton != null) 
                InkWell(
                  onTap: () => onKeyPress(specialValue),
                  child: specialButton!,
                )
              else 
                _buildButton(specialValue, () => onKeyPress(specialValue)),
                
              _buildButton('0', () => onKeyPress('0')),
              // Phím xoá
              _buildEraseButton(),
            ],
          ),
        ],
      ),
    );
  }
}