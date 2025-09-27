import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month; // Hiển thị theo tháng

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1), // Ngày bắt đầu của lịch
              lastDay: DateTime.utc(3000, 1, 1), // Ngày kết thúc của lịch
              focusedDay:
                  _focusedDay, // Ngày đang được tập trung (thường là ngày hiện tại)
              calendarFormat:
                  _calendarFormat, // Định dạng lịch (tháng, 2 tuần, tuần)
              locale: 'vi_VN', // Đặt ngôn ngữ hiển thị là Tiếng Việt

              // Cài đặt giao diện Header
              headerStyle: const HeaderStyle(
                formatButtonVisible: false, // Ẩn nút chuyển đổi định dạng
                titleCentered: true,
              ),

              // Cài đặt giao diện Ngày
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.lightBlue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),

              // Xử lý sự kiện khi chọn ngày
              selectedDayPredicate: (day) {
                // Chỉ định ngày được chọn
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                // Cập nhật trạng thái khi người dùng chọn một ngày khác
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay; // Cập nhật ngày tập trung
                    // Sau này bạn có thể tải dữ liệu giao dịch cho ngày này
                  });
                }
              },

              // Xử lý sự kiện khi thay đổi tháng/năm
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },

              // Tùy chọn chuyển đổi định dạng lịch (tháng, 2 tuần, tuần)
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
            ),

            const Divider(),

            //Hiển thị thông tin ngày đã chọn
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _selectedDay == null
                    ? 'Vui lòng chọn một ngày'
                    : 'Ngày đã chọn: ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
