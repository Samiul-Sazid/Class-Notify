import 'package:flutter/material.dart';
import '../view_models/settings_view_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../core/glass_card.dart';

/// Settings view for configuring reminders, API key, theme, and data management.
class SettingsView extends StatelessWidget {
  final SettingsViewModel viewModel;
  final VoidCallback? onThemeChanged;

  const SettingsView({
    super.key,
    required this.viewModel,
    this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildReminderSection(context),
                _buildNotificationSection(context),
                _buildAISection(context),
                _buildAppearanceSection(context),
                _buildDataSection(context),
                _buildAboutSection(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
    );
  }

  // --- Reminder Settings ---
  Widget _buildReminderSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _buildSection(
      context,
      title: 'Reminder',
      icon: Icons.alarm_outlined,
      children: [
        Text(
          'Notify me before class starts:',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: SettingsViewModel.reminderOptions.map((minutes) {
            final isSelected = viewModel.reminderLeadMinutes == minutes;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ChoiceChip(
                label: Text('$minutes min'),
                selected: isSelected,
                onSelected: (_) => viewModel.setReminderMinutes(minutes),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- Notification Settings ---
  Widget _buildNotificationSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Notifications',
      icon: Icons.notifications_outlined,
      children: [
        _buildSwitchTile(
          context,
          title: 'Sound',
          subtitle: 'Play notification sound',
          value: viewModel.isSoundEnabled,
          onChanged: viewModel.toggleSound,
        ),
        _buildSwitchTile(
          context,
          title: 'Vibration',
          subtitle: 'Vibrate on notification',
          value: viewModel.isVibrateEnabled,
          onChanged: viewModel.toggleVibrate,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => viewModel.sendTestNotification(),
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text('Send Test Notification'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- AI Configuration ---
  Widget _buildAISection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _buildSection(
      context,
      title: 'AI Configuration',
      icon: Icons.auto_awesome_outlined,
      children: [
        Text(
          'Gemini API Key',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Required for AI-powered routine image parsing. '
          'Get a free key from aistudio.google.com/apikey',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
        _ApiKeyInput(
          initialValue: viewModel.geminiApiKey ?? '',
          onSaved: (key) => viewModel.setApiKey(key),
        ),
      ],
    );
  }

  // --- Appearance ---
  Widget _buildAppearanceSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Appearance',
      icon: Icons.palette_outlined,
      children: [
        _buildSwitchTile(
          context,
          title: 'Dark Mode',
          subtitle: 'Use dark color scheme',
          value: viewModel.isDarkMode,
          onChanged: (val) {
            viewModel.toggleDarkMode(val);
            onThemeChanged?.call();
          },
        ),
      ],
    );
  }

  // --- Data Management ---
  Widget _buildDataSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _buildSection(
      context,
      title: 'Data',
      icon: Icons.storage_outlined,
      children: [
        Row(
          children: [
            Text('Total classes: ', style: textTheme.bodyMedium),
            Text(
              '${viewModel.totalClasses}',
              style: textTheme.titleMedium?.copyWith(color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _confirmClearData(context),
            icon: const Icon(
              Icons.delete_outline,
              size: 18,
              color: AppColors.danger,
            ),
            label: const Text(
              'Clear All Data',
              style: TextStyle(color: AppColors.danger),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: AppColors.danger.withValues(alpha: 0.3)),
            ),
          ),
        ),
      ],
    );
  }

  // --- About ---
  Widget _buildAboutSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _buildSection(
      context,
      title: 'About',
      icon: Icons.info_outline,
      children: [
        Text('Class Routine Notifier', style: textTheme.titleMedium),
        const SizedBox(height: 2),
        Text('Version 1.0.0', style: textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          'Built with Flutter 💙',
          style: textTheme.bodySmall?.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }

  // --- Helpers ---

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.bodyMedium),
                Text(subtitle, style: textTheme.bodySmall),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Future<void> _confirmClearData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will delete all your classes and cancel all '
          'scheduled notifications. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await viewModel.clearAllData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared.')),
        );
      }
    }
  }
}

/// API key input with save button — a tiny StatefulWidget.
class _ApiKeyInput extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onSaved;

  const _ApiKeyInput({required this.initialValue, required this.onSaved});

  @override
  State<_ApiKeyInput> createState() => _ApiKeyInputState();
}

class _ApiKeyInputState extends State<_ApiKeyInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Paste your API key here',
              filled: true,
              fillColor: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            widget.onSaved(_controller.text.trim());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('API key saved!')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
