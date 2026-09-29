import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../today/views/today_view.dart';
import '../../today/view_models/today_view_model.dart';
import '../../timetable/views/timetable_view.dart';
import '../../timetable/view_models/timetable_view_model.dart';
import '../../scanner/views/scanner_view.dart';
import '../../scanner/view_models/scanner_view_model.dart';
import '../../settings/views/settings_view.dart';
import '../../settings/view_models/settings_view_model.dart';

/// Main app shell with bottom navigation.
///
/// ## Flutter Learning Note:
/// This is a `StatefulWidget` because it manages the currently selected tab
/// index. It uses `PageView` with a `PageController` for smooth animated
/// transitions between tabs.
///
/// The ViewModels are passed in from `main.dart` (dependency injection via
/// constructor). This keeps the navigation shell "dumb" — it just connects
/// ViewModels to their Views.
class MainNavigationScreen extends StatefulWidget {
  final TodayViewModel todayViewModel;
  final TimetableViewModel timetableViewModel;
  final ScannerViewModel scannerViewModel;
  final SettingsViewModel settingsViewModel;
  final VoidCallback? onThemeChanged;

  const MainNavigationScreen({
    super.key,
    required this.todayViewModel,
    required this.timetableViewModel,
    required this.scannerViewModel,
    required this.settingsViewModel,
    this.onThemeChanged,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: [
          TodayView(viewModel: widget.todayViewModel),
          TimetableView(viewModel: widget.timetableViewModel),
          ScannerView(viewModel: widget.scannerViewModel),
          SettingsView(
            viewModel: widget.settingsViewModel,
            onThemeChanged: widget.onThemeChanged,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.today_outlined, Icons.today, 'Today'),
              _buildNavItem(1, Icons.calendar_view_week_outlined,
                  Icons.calendar_view_week, 'Timetable'),
              _buildNavItem(
                  2, Icons.qr_code_scanner_outlined, Icons.qr_code_scanner, 'Scan'),
              _buildNavItem(3, Icons.settings_outlined, Icons.settings, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
  ) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
              size: 22,
              color: isSelected ? AppColors.primary : AppColors.textTertiaryDark,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
