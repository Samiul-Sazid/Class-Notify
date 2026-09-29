import 'package:flutter/material.dart';
import '../../data/models/class_session.dart';
import '../../core/constants/app_colors.dart';

/// A polished card displaying a single class session.
///
/// Features a color bar on the left, course code, section badge,
/// time range, room info with type icon, group tag, and notification toggle.
class ClassSessionCard extends StatelessWidget {
  final ClassSession session;
  final VoidCallback? onTap;
  final VoidCallback? onToggleNotification;
  final VoidCallback? onDelete;
  final bool showDayBadge;
  final bool isActive;
  final bool hasPassed;

  const ClassSessionCard({
    super.key,
    required this.session,
    this.onTap,
    this.onToggleNotification,
    this.onDelete,
    this.showDayBadge = false,
    this.isActive = false,
    this.hasPassed = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Dismissible(
      key: Key(session.id),
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.danger),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: isActive
                ? Border.all(color: AppColors.accent, width: 2)
                : Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.04),
                  ),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? AppColors.accent.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: isActive ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Opacity(
            opacity: hasPassed ? 0.5 : 1.0,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Color bar on the left
                  Container(
                    width: 5,
                    decoration: BoxDecoration(
                      color: session.color,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: Course Code + Section badge + Active badge
                          Row(
                            children: [
                              // Course code
                              Expanded(
                                child: Text(
                                  session.courseCode,
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              // Section badge
                              if (session.section.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        session.color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    session.section,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: session.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              if (session.group != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.surfaceVariantDark
                                        : AppColors.surfaceVariantLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    session.group!,
                                    style: textTheme.labelSmall,
                                  ),
                                ),
                              ],
                              if (isActive) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.accent.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: AppColors.accent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'LIVE',
                                        style: textTheme.labelSmall?.copyWith(
                                          color: AppColors.accent,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Time range
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                              const SizedBox(width: 6),
                              Text(session.timeRange, style: textTheme.bodySmall),
                              const SizedBox(width: 12),
                              // Duration badge
                              Text(
                                '${session.durationMinutes} min',
                                style: textTheme.labelSmall?.copyWith(
                                  color: isDark
                                      ? AppColors.textTertiaryDark
                                      : AppColors.textTertiaryLight,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Room info
                          Row(
                            children: [
                              Icon(
                                _roomIcon(session.roomType),
                                size: 14,
                                color: AppColors.roomColor(session.roomType),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  session.fullRoom,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.roomColor(session.roomType),
                                  ),
                                ),
                              ),
                              // Notification toggle
                              if (onToggleNotification != null)
                                GestureDetector(
                                  onTap: onToggleNotification,
                                  child: Icon(
                                    session.isNotificationEnabled
                                        ? Icons.notifications_active_rounded
                                        : Icons.notifications_off_outlined,
                                    size: 20,
                                    color: session.isNotificationEnabled
                                        ? AppColors.primary
                                        : (isDark
                                            ? AppColors.textTertiaryDark
                                            : AppColors.textTertiaryLight),
                                  ),
                                ),
                            ],
                          ),

                          // Instructor
                          if (session.instructor != null &&
                              session.instructor!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline_rounded,
                                  size: 14,
                                  color: isDark
                                      ? AppColors.textTertiaryDark
                                      : AppColors.textTertiaryLight,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  session.instructor!,
                                  style: textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ],

                          // Note
                          if (session.note != null &&
                              session.note!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              session.note!,
                              style: textTheme.labelSmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
