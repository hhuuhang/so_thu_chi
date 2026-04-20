# 💰 Sổ Thu Chi - Personal Expense Manager

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

**Sổ Thu Chi** là một ứng dụng quản lý tài chính cá nhân hiện đại, giúp bạn theo dõi thu nhập và chi tiêu hàng ngày một cách dễ dàng và hiệu quả. Với giao diện tinh tế, hỗ trợ cả Light và Dark mode, cùng các biểu đồ trực quan, bạn sẽ luôn nắm quyền kiểm soát túi tiền của mình.

---

## ✨ Tính Năng Nổi Bật

### 📅 Quản Lý Theo Lịch
Theo dõi dòng tiền hàng ngày thông qua giao diện lịch trực quan. Biết chính xác bạn đã chi tiêu bao nhiêu vào ngày nào.

### 📊 Báo Cáo Chuyên Sâu
- **Biểu đồ tròn (Pie Chart)**: Phân tích tỷ trọng chi tiêu theo từng danh mục (Ăn uống, Mua sắm, Di chuyển...).
- **Thống kê tổng quát**: Xem nhanh Tổng thu, Tổng chi và Số dư trong tháng/năm.
- **Lọc theo thời gian**: Dễ dàng xem lại dữ liệu cũ theo tháng hoặc năm.

### 🎨 Trải Nghiệm Người Dùng Đỉnh Cao
- **Chế độ Sáng/Tối (Light/Dark Mode)**: Tự động chuyển đổi hoặc lựa chọn theo sở thích.
- **Đa ngôn ngữ**: Hỗ trợ đầy đủ tiếng Việt 🇻🇳 và tiếng Anh 🇬🇧.
- **Bàn phím tùy chỉnh**: Nhập liệu số tiền cực nhanh với Numpad chuyên dụng tích hợp sẵn.

### 🔒 An Toàn & Bảo Mật
Dữ liệu của bạn được lưu trữ hoàn toàn cục bộ trên thiết bị bằng **SQLite**, đảm bảo quyền riêng tư tuyệt đối.

---

## 📸 Hình Ảnh Ứng Dụng

| Màn Hình Nhập Liệu | Báo Cáo Biểu Đồ | Lịch Giao Dịch |
|:---:|:---:|:---:|
| <img src="assets/screenshots/input_dark.png" width="250"> | <img src="assets/screenshots/report_dark.png" width="250"> | <img src="assets/screenshots/calendar_dark.png" width="250"> |
| *Nhập liệu nhanh chóng* | *Phân tích chi tiết* | *Quản lý theo ngày* |

---

## 🛠 Công Nghệ Sử Dụng

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Local Database**: SQLite (`sqflite`)
- **Localization**: `easy_localization`
- **Charts**: `fl_chart`
- **Themes**: Material 3 với Custom Semantic Colors

---

## 🚀 Bắt Đầu Ngay

### Yêu Cầu Hệ Thống
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0

### Cài Đặt

1. **Clone repository:**
   ```bash
   git clone https://github.com/hhuuhang/so_thu_chi.git
   ```

2. **Cài đặt các gói phụ thuộc:**
   ```bash
   flutter pub get
   ```

3. **Chạy ứng dụng:**
   ```bash
   flutter run
   ```

---

## 🤝 Đóng Góp

Mọi đóng góp nhằm cải thiện ứng dụng đều được trân trọng. Hãy fork project và tạo pull request hoặc mở issue nếu bạn phát hiện lỗi.

## 📄 Giấy Phép

Dự án này được phân phối dưới giấy phép MIT. Xem file `LICENSE` để biết thêm chi tiết.

---
*Phát triển bởi [hhuuhang](https://github.com/hhuuhang) với ❤️*
