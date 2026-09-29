import 'package:flutter/material.dart';
import 'core/constants/app_theme.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'data/repositories/routine_repository.dart';
import 'ui/features/home/views/main_navigation_screen.dart';
import 'ui/features/today/view_models/today_view_model.dart';
import 'ui/features/timetable/view_models/timetable_view_model.dart';
import 'ui/features/scanner/view_models/scanner_view_model.dart';
import 'ui/features/settings/view_models/settings_view_model.dart';

/// Application entry point.
///
/// ## Flutter Learning Note: Application Bootstrap
///
/// This is where everything comes together. The `main()` function:
/// 1. Ensures Flutter bindings are initialized (required before async work)
/// 2. Initializes platform services (notifications, storage)
/// 3. Creates the repository (data layer)
/// 4. Loads persisted data
/// 5. Creates ViewModels (presentation layer)
/// 6. Mounts the widget tree
///
/// This is **manual dependency injection** — we create dependencies in
/// the right order and pass them via constructors. For larger apps, you
/// might use a DI framework like `get_it` or `provider`, but for learning
/// purposes, manual DI is more transparent and easier to understand.
void main() async {
  // Step 1: Ensure Flutter engine is ready before async work
  WidgetsFlutterBinding.ensureInitialized();

  // Step 2: Initialize platform services
  final storageService = StorageService();
  await storageService.init();

  final notificationService = NotificationService();
  await notificationService.init();

  // Step 3: Create repository and load persisted data
  final repository = RoutineRepository(
    storage: storageService,
    notifications: notificationService,
  );
  await repository.init();

  // Step 4: Run the app
  runApp(
    ClassRoutineApp(
      repository: repository,
      notificationService: notificationService,
    ),
  );
}

/// Root widget of the application.
///
/// ## Flutter Learning Note:
/// This is a `StatefulWidget` because it needs to react to theme changes
/// (dark/light mode toggle in settings). When the user toggles the theme,
/// `_onThemeChanged()` is called, which triggers `setState()`, causing
/// the entire MaterialApp to rebuild with the new theme.
class ClassRoutineApp extends StatefulWidget {
  final RoutineRepository repository;
  final NotificationService notificationService;

  const ClassRoutineApp({
    super.key,
    required this.repository,
    required this.notificationService,
  });

  @override
  State<ClassRoutineApp> createState() => _ClassRoutineAppState();
}

class _ClassRoutineAppState extends State<ClassRoutineApp> {
  // ViewModels — created once and live for the app's entire lifetime
  late final TodayViewModel _todayViewModel;
  late final TimetableViewModel _timetableViewModel;
  late final ScannerViewModel _scannerViewModel;
  late final SettingsViewModel _settingsViewModel;

  @override
  void initState() {
    super.initState();

    _todayViewModel = TodayViewModel(repository: widget.repository);
    _timetableViewModel = TimetableViewModel(repository: widget.repository);
    _scannerViewModel = ScannerViewModel(repository: widget.repository);
    _settingsViewModel = SettingsViewModel(
      repository: widget.repository,
      notifications: widget.notificationService,
    );
  }

  @override
  void dispose() {
    _todayViewModel.dispose();
    _timetableViewModel.dispose();
    _scannerViewModel.dispose();
    _settingsViewModel.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    // Trigger a rebuild so MaterialApp picks up the new theme
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.repository.settings.isDarkMode;

    return MaterialApp(
      title: 'Class Routine',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: MainNavigationScreen(
        todayViewModel: _todayViewModel,
        timetableViewModel: _timetableViewModel,
        scannerViewModel: _scannerViewModel,
        settingsViewModel: _settingsViewModel,
        onThemeChanged: _onThemeChanged,
      ),
    );
  }
}
