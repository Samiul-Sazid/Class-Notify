import 'package:flutter/material.dart';
import '../view_models/timetable_view_model.dart';
import '../../../core/class_session_card.dart';
import '../../../../core/constants/app_colors.dart';
import 'edit_class_sheet.dart';

/// Weekly timetable view with day tabs and class cards.
class TimetableView extends StatelessWidget {
  final TimetableViewModel viewModel;

  const TimetableView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Day selector tabs
              _buildDaySelector(context),

              const SizedBox(height: 8),

              // Class list
              Expanded(child: _buildClassList(context)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Text('Timetable', style: textTheme.headlineMedium),
          const Spacer(),
          // Add class button
          IconButton(
            onPressed: () => _showAddClassSheet(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: viewModel.weekDays.length,
        itemBuilder: (context, index) {
          final day = viewModel.weekDays[index];
          final isSelected = day == viewModel.selectedDay;
          final count = viewModel.dayClassCounts[day] ?? 0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => viewModel.selectDay(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariantLight),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      viewModel.dayNameShort(day),
                      style: textTheme.titleMedium?.copyWith(
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.25)
                              : AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClassList(BuildContext context) {
    final sessions = viewModel.sessionsForSelectedDay;

    if (sessions.isEmpty) {
      return _buildEmptyDay(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 100),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return ClassSessionCard(
          session: session,
          onTap: () => _showEditClassSheet(context, session),
          onToggleNotification: () =>
              viewModel.toggleNotification(session.id),
          onDelete: () => viewModel.deleteSession(session.id),
        );
      },
    );
  }

  Widget _buildEmptyDay(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dayName = viewModel.dayNameFull(viewModel.selectedDay);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 64,
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No classes on $dayName',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _showAddClassSheet(context),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add a class'),
          ),
        ],
      ),
    );
  }

  void _showAddClassSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditClassSheet(
        initialDay: viewModel.selectedDay,
        onSave: (session) => viewModel.saveSession(session),
      ),
    );
  }

  void _showEditClassSheet(BuildContext context, session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditClassSheet(
        session: session,
        onSave: (updated) => viewModel.saveSession(updated),
      ),
    );
  }
}
