import 'package:flutter/material.dart';
import '../../../../data/models/user_settings.dart';
import '../../../../data/repositories/routine_repository.dart';
import '../../../../core/services/notification_service.dart';

/// ViewModel for the Settings screen.
class SettingsViewModel extends ChangeNotifier {
  final RoutineRepository repository;
  final NotificationService notifications;

  SettingsViewModel({
    required this.repository,
    required this.notifications,
  }) {
    repository.addListener(_onDataChanged);
  }

  void _onDataChanged() => notifyListeners();

  // --- Exposed State ---

  UserSettings get settings => repository.settings;

  int get reminderLeadMinutes => settings.reminderLeadMinutes;
  bool get isSoundEnabled => settings.isSoundEnabled;
  bool get isVibrateEnabled => settings.isVibrateEnabled;
  String? get geminiApiKey => settings.geminiApiKey;
  bool get isDarkMode => settings.isDarkMode;
  String get semesterLabel => settings.semesterLabel;
  int get totalClasses => repository.allSessions.length;

  /// Available reminder lead time options.
  static const List<int> reminderOptions = [5, 10, 15, 30];

  // --- Actions ---

  Future<void> setReminderMinutes(int minutes) async {
    await repository.updateSettings(
      settings.copyWith(reminderLeadMinutes: minutes),
    );
  }

  Future<void> toggleSound(bool value) async {
    await repository.updateSettings(
      settings.copyWith(isSoundEnabled: value),
    );
  }

  Future<void> toggleVibrate(bool value) async {
    await repository.updateSettings(
      settings.copyWith(isVibrateEnabled: value),
    );
  }

  Future<void> setApiKey(String key) async {
    await repository.updateSettings(
      settings.copyWith(geminiApiKey: key),
    );
  }

  Future<void> toggleDarkMode(bool value) async {
    await repository.updateSettings(
      settings.copyWith(isDarkMode: value),
    );
  }

  Future<void> setSemesterLabel(String label) async {
    await repository.updateSettings(
      settings.copyWith(semesterLabel: label),
    );
  }

  /// Sends an instant test notification.
  Future<void> sendTestNotification() async {
    await notifications.sendTestNotification();
  }

  /// Clears all class data (with confirmation already handled by UI).
  Future<void> clearAllData() async {
    await repository.clearAll();
  }

  @override
  void dispose() {
    repository.removeListener(_onDataChanged);
    super.dispose();
  }
}
