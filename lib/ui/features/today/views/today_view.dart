import 'package:flutter/material.dart';
import '../view_models/today_view_model.dart';
import '../../../core/class_session_card.dart';
import '../../../core/glass_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/time_utils.dart';

/// Today's Dashboard — the first screen users see.
///
/// ## Flutter Learning Note:
/// This is a `StatelessWidget` because it has no internal mutable state.
/// All state comes from the `TodayViewModel` via `ListenableBuilder`.
///
/// `ListenableBuilder` is Flutter's recommended way to listen to a
/// ChangeNotifier and rebuild the widget tree when state changes.
/// It's more efficient than `setState` because only the builder's
/// subtree rebuilds, not the entire widget.
class TodayView extends StatelessWidget {
  final TodayViewModel viewModel;

  const TodayView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return SafeArea(
          child: CustomScrollView(
            slivers: [
              // Greeting header
              SliverToBoxAdapter(child: _buildHeader(context)),

              // Next class spotlight card
              if (viewModel.nextClass != null)
                SliverToBoxAdapter(child: _buildNextClassCard(context)),

              // Today's timeline
              if (viewModel.hasClassesToday)
                SliverToBoxAdapter(child: _buildTimelineHeader(context)),

              if (viewModel.hasClassesToday)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final session = viewModel.todaySessions[index];
                      return ClassSessionCard(
                        session: session,
                        isActive: viewModel.isActive(session),
                        hasPassed: viewModel.hasPassed(session),
                      );
                    },
                    childCount: viewModel.todaySessions.length,
                  ),
                ),

              // Empty state
              if (!viewModel.hasAnyClasses)
                SliverFillRemaining(child: _buildEmptyState(context)),

              if (viewModel.hasAnyClasses && !viewModel.hasClassesToday)
                SliverFillRemaining(child: _buildNoClassesToday(context)),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${viewModel.greeting} 👋',
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            viewModel.formattedDate,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextClassCard(BuildContext context) {
    final next = viewModel.nextClass!;
    final textTheme = Theme.of(context).textTheme;
    final isActive = viewModel.currentClass?.id == next.id;

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderColor: isActive ? AppColors.accent : AppColors.primary.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? AppColors.accentGradient
                      : AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? '🔴 NOW' : '⏰ UP NEXT',
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                viewModel.nextClassCountdown,
                style: textTheme.titleMedium?.copyWith(
                  color: isActive ? AppColors.accent : AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Course code and section
          Row(
            children: [
              Expanded(
                child: Text(
                  next.courseCode,
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (next.section.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: next.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    next.section,
                    style: textTheme.labelLarge?.copyWith(
                      color: next.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Time and room
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondaryDark),
              const SizedBox(width: 6),
              Text(next.timeRange, style: textTheme.bodyMedium),
              const SizedBox(width: 16),
              Icon(
                _roomIcon(next.roomType),
                size: 16,
                color: AppColors.roomColor(next.roomType),
              ),
              const SizedBox(width: 6),
              Text(
                next.fullRoom,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.roomColor(next.roomType),
                ),
              ),
            ],
          ),

          if (next.group != null || next.instructor != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                if (next.group != null) ...[
                  const Icon(Icons.group_outlined, size: 14, color: AppColors.textTertiaryDark),
                  const SizedBox(width: 4),
                  Text(next.group!, style: textTheme.bodySmall),
                  const SizedBox(width: 12),
                ],
                if (next.instructor != null) ...[
                  const Icon(Icons.person_outline, size: 14, color: AppColors.textTertiaryDark),
                  const SizedBox(width: 4),
                  Text(next.instructor!, style: textTheme.bodySmall),
                ],
              ],
            ),
          ],

          // Day badge (when next class is not today)
          if (next.dayOfWeek != DateTime.now().weekday) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                TimeUtils.getDayName(next.dayOfWeek),
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Text(
            "Today's Schedule",
            style: textTheme.titleLarge,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${viewModel.todayClassCount} classes',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Routine Yet',
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload a photo of your class routine\nor add classes manually to get started.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoClassesToday(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'No Classes Today!',
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Enjoy your day off.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            if (viewModel.nextClass != null) ...[
              const SizedBox(height: 16),
              Text(
                'Next: ${viewModel.nextClass!.courseCode} '
                '(${TimeUtils.getDayName(viewModel.nextClass!.dayOfWeek)})',
                style: textTheme.bodySmall?.copyWith(color: AppColors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _roomIcon(String roomType) {
    final type = roomType.toLowerCase();
    if (type.contains('lab')) return Icons.science_outlined;
    if (type.contains('tutorial')) return Icons.groups_outlined;
    return Icons.class_outlined;
  }
}
