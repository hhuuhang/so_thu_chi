import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _selectedLang;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLang ??= context.locale.languageCode;
  }

  Future<void> _changeLanguage(String langCode) async {
    final newLocale = Locale(langCode);
    if (!mounted) return;

    await context.setLocale(newLocale);

    if (mounted) {
      setState(() {
        _selectedLang = langCode;
      });
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('langCode', langCode);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // ── App Header ──────────────────────────────────────
            _buildAppHeader(colors),
            const SizedBox(height: 28),

            // ── Section: General ────────────────────────────────
            _buildSectionTitle('settingsGeneral'.tr(), colors),
            const SizedBox(height: 10),
            _buildSettingsCard(
              colors: colors,
              children: [
                // Theme selector
                _buildThemeTile(colors, themeProvider),
                _buildDivider(colors),
                // Language selector
                _buildLanguageTile(colors),
              ],
            ),
            const SizedBox(height: 28),

            // ── Section: About ──────────────────────────────────
            _buildSectionTitle('settingsAbout'.tr(), colors),
            const SizedBox(height: 10),
            _buildSettingsCard(
              colors: colors,
              children: [
                _buildInfoTile(
                  colors: colors,
                  icon: Icons.info_outline_rounded,
                  title: 'appVersion'.tr(),
                  trailing: Text(
                    '1.0.0',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── App Header ──────────────────────────────────────────────
  Widget _buildAppHeader(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.primary,
                  colors.primary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'settings'.tr(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'appTitle'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Title ───────────────────────────────────────────
  Widget _buildSectionTitle(String title, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: colors.settingsSectionTitle,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ── Settings Card Container ────────────────────────────────
  Widget _buildSettingsCard({
    required ColorScheme colors,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.settingsTileBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // ── Divider inside card ─────────────────────────────────────
  Widget _buildDivider(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: colors.subtleDivider),
    );
  }

  // ── Theme Selector Tile ─────────────────────────────────────
  Widget _buildThemeTile(ColorScheme colors, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                color: colors.settingsIcon,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                'settingsTheme'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Segmented theme selector
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colors.brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _buildThemeOption(
                  colors: colors,
                  icon: Icons.light_mode_rounded,
                  label: 'themeLight'.tr(),
                  isSelected: themeProvider.isLight,
                  onTap: () =>
                      themeProvider.setThemeMode(ThemeMode.light),
                ),
                _buildThemeOption(
                  colors: colors,
                  icon: Icons.dark_mode_rounded,
                  label: 'themeDark'.tr(),
                  isSelected: themeProvider.isDark,
                  onTap: () =>
                      themeProvider.setThemeMode(ThemeMode.dark),
                ),
                _buildThemeOption(
                  colors: colors,
                  icon: Icons.settings_brightness_rounded,
                  label: 'themeSystem'.tr(),
                  isSelected: themeProvider.isSystem,
                  onTap: () =>
                      themeProvider.setThemeMode(ThemeMode.system),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required ColorScheme colors,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Colors.white
                    : colors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Language Tile ───────────────────────────────────────────
  Widget _buildLanguageTile(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Icon(
            Icons.language_rounded,
            color: colors.settingsIcon,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'language'.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colors.brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.subtleDivider),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLang,
                isDense: true,
                borderRadius: BorderRadius.circular(12),
                dropdownColor: colors.settingsTileBg,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'vi',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🇻🇳'),
                        const SizedBox(width: 8),
                        Text(
                          'Tiếng Việt',
                          style: TextStyle(color: colors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'en',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🇬🇧'),
                        const SizedBox(width: 8),
                        Text(
                          'English',
                          style: TextStyle(color: colors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _changeLanguage(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Tile ───────────────────────────────────────────────
  Widget _buildInfoTile({
    required ColorScheme colors,
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Icon(icon, color: colors.settingsIcon, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
