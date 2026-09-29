import 'package:flutter/material.dart';
import '../view_models/scanner_view_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../core/glass_card.dart';

/// Review & verify extracted classes before importing them.
class ReviewExtractedRoutineView extends StatelessWidget {
  final ScannerViewModel viewModel;

  const ReviewExtractedRoutineView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sessions = viewModel.extractedSessions;

    // Group sessions by day
    final grouped = <int, List<int>>{};
    for (var i = 0; i < sessions.length; i++) {
      grouped.putIfAbsent(sessions[i].dayOfWeek, () => []).add(i);
    }

    // Sort days in Sat-Thu order
    final sortedDays = grouped.keys.toList()
      ..sort((a, b) {
        const order = {6: 0, 7: 1, 1: 2, 2: 3, 3: 4, 4: 5, 5: 6};
        return (order[a] ?? a).compareTo(order[b] ?? b);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary header
        GlassCard(
          borderColor: AppColors.accent.withValues(alpha: 0.3),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Found ${sessions.length} classes',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'across ${sortedDays.length} days — review before importing',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Grouped sessions by day
        ...sortedDays.map((day) {
          final indices = grouped[day]!;
          return _buildDaySection(context, day, indices);
        }),

        const SizedBox(height: 16),

        // Import + Cancel buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: sessions.isEmpty
                      ? null
                      : () => _importSessions(context),
                  icon: const Icon(Icons.download_done_rounded),
                  label: Text('Import ${sessions.length} Classes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => viewModel.reset(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Discard'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDaySection(BuildContext context, int day, List<int> indices) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  TimeUtils.getDayName(day),
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${indices.length} classes',
                style: textTheme.labelSmall,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Session cards
          ...indices.map((index) {
            final session = viewModel.extractedSessions[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                ),
              ),
              child: Row(
                children: [
                  // Color indicator
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: session.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              session.courseCode,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            if (session.section.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text(
                                '(${session.section})',
                                style: textTheme.labelSmall?.copyWith(
                                  color: session.color,
                                ),
                              ),
                            ],
                            if (session.group != null) ...[
                              const SizedBox(width: 4),
                              Text(
                                session.group!,
                                style: textTheme.labelSmall,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${session.timeRange}  •  ${session.fullRoom}',
                          style: textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),

                  // Delete button
                  IconButton(
                    onPressed: () => viewModel.removeExtractedSession(index),
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.danger,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _importSessions(BuildContext context) async {
    // Show confirmation dialog
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Schedule'),
        content: const Text(
          'Would you like to replace your existing schedule or add to it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Add to Existing'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Replace All'),
          ),
        ],
      ),
    );

    if (result == null) return; // Cancelled

    await viewModel.importExtractedSessions(clearExisting: result);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Imported ${viewModel.extractedSessions.length} classes! '
            'Notifications scheduled.',
          ),
        ),
      );
    }
  }
}
