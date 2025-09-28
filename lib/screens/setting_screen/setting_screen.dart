import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen> {
  String? _selectedLang;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // FIX LỖI: Truy cập context.locale an toàn tại đây
    _selectedLang ??= context.locale.languageCode;
  }

  Future<void> _changeLanguage(String langCode) async {
        final newLocale = Locale(langCode);

        if (!mounted) return;

        // 1. Thay đổi ngôn ngữ toàn cục.
        // Dòng này khiến toàn bộ app UI được rebuild ngay lập tức.
        await context.setLocale(newLocale); 

        // 2. Cập nhật trạng thái Dropdown cục bộ
        if (mounted) {
            setState(() {
                _selectedLang = langCode; 
            });
        }
        
        // 3. Lưu SharedPreferences sau cùng
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('langCode', langCode);
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("settings".tr()), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "language".tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedLang,
              items: const [
                DropdownMenuItem(
                  value: "vi",
                  child: Text("Tiếng Việt"),
                ),
                DropdownMenuItem(
                  value: "en",
                  child: Text("English"),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  _changeLanguage(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}