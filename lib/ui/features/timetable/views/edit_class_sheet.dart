import 'package:flutter/material.dart';
import '../../../../data/models/class_session.dart';
import '../../../../data/models/routine_slot.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/time_utils.dart';

/// Modal bottom sheet for creating or editing a class session.
///
/// ## Flutter Learning Note:
/// This is a `StatefulWidget` because it manages form input state locally.
/// Unlike ViewModels (which manage app-wide state), form state is temporary
/// — it only exists while the sheet is open. Once the user taps "Save",
/// we pass the result back via the `onSave` callback and the sheet closes.
class EditClassSheet extends StatefulWidget {
  final ClassSession? session; // null = creating new
  final int? initialDay;
  final Function(ClassSession) onSave;

  const EditClassSheet({
    super.key,
    this.session,
    this.initialDay,
    required this.onSave,
  });

  @override
  State<EditClassSheet> createState() => _EditClassSheetState();
}

class _EditClassSheetState extends State<EditClassSheet> {
  late TextEditingController _courseCodeController;
  late TextEditingController _sectionController;
  late TextEditingController _roomNumberController;
  late TextEditingController _instructorController;
  late TextEditingController _noteController;

  late int _selectedDay;
  late String _roomType;
  String? _group;
  late int _startHour, _startMinute, _endHour, _endMinute;

  final _roomTypes = ['Lecture Room', 'Lab Room', 'Tutorial Room'];
  final _groups = [null, 'G-1', 'G-2', 'G-3', 'G-4'];

  @override
  void initState() {
    super.initState();
    final s = widget.session;

    _courseCodeController = TextEditingController(text: s?.courseCode ?? '');
    _sectionController = TextEditingController(text: s?.section ?? '');
    _roomNumberController = TextEditingController(text: s?.roomNumber ?? '');
    _instructorController = TextEditingController(text: s?.instructor ?? '');
    _noteController = TextEditingController(text: s?.note ?? '');

    _selectedDay = s?.dayOfWeek ?? widget.initialDay ?? DateTime.now().weekday;
    _roomType = s?.roomType ?? 'Lecture Room';
    _group = s?.group;
    _startHour = s?.startHour ?? 9;
    _startMinute = s?.startMinute ?? 0;
    _endHour = s?.endHour ?? 10;
    _endMinute = s?.endMinute ?? 15;
  }

  @override
  void dispose() {
    _courseCodeController.dispose();
    _sectionController.dispose();
    _roomNumberController.dispose();
    _instructorController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final isEditing = widget.session != null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              isEditing ? 'Edit Class' : 'Add New Class',
              style: textTheme.headlineSmall,
            ),
          ),

          // Form fields
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Code
                  _buildTextField(
                    controller: _courseCodeController,
                    label: 'Course Code',
                    hint: 'e.g. CSE 219, PROG 302',
                    icon: Icons.book_outlined,
                  ),
                  const SizedBox(height: 14),

                  // Section + Group in a row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          controller: _sectionController,
                          label: 'Section',
                          hint: 'e.g. MM, SE, SCD',
                          icon: Icons.label_outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown<String?>(
                          label: 'Group',
                          value: _group,
                          items: _groups,
                          displayText: (g) => g ?? 'None',
                          onChanged: (val) => setState(() => _group = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Day selector
                  _buildLabel('Day'),
                  const SizedBox(height: 6),
                  _buildDayChips(),
                  const SizedBox(height: 14),

                  // Time slot presets
                  _buildLabel('Time Slot'),
                  const SizedBox(height: 6),
                  _buildSlotPresets(),
                  const SizedBox(height: 8),

                  // Manual time pickers
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimePicker(
                          label: 'Start',
                          hour: _startHour,
                          minute: _startMinute,
                          onChanged: (h, m) =>
                              setState(() { _startHour = h; _startMinute = m; }),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('→', style: TextStyle(fontSize: 20)),
                      ),
                      Expanded(
                        child: _buildTimePicker(
                          label: 'End',
                          hour: _endHour,
                          minute: _endMinute,
                          onChanged: (h, m) =>
                              setState(() { _endHour = h; _endMinute = m; }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Room type + number
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown<String>(
                          label: 'Room Type',
                          value: _roomType,
                          items: _roomTypes,
                          displayText: (t) => t,
                          onChanged: (val) =>
                              setState(() => _roomType = val ?? 'Lecture Room'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _roomNumberController,
                          label: 'Room No.',
                          hint: 'e.g. 1002',
                          icon: Icons.meeting_room_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Instructor
                  _buildTextField(
                    controller: _instructorController,
                    label: 'Instructor (optional)',
                    hint: 'e.g. Sujan Sir',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 14),

                  // Note
                  _buildTextField(
                    controller: _noteController,
                    label: 'Note (optional)',
                    hint: 'e.g. Bring lab notebook',
                    icon: Icons.note_outlined,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Save button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  isEditing ? 'Update Class' : 'Add Class',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: isDark
                ? AppColors.surfaceVariantDark
                : AppColors.surfaceVariantLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) displayText,
    required ValueChanged<T?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceVariantDark
                : AppColors.surfaceVariantLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(displayText(item)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDayChips() {
    const days = [6, 7, 1, 2, 3, 4]; // Sat-Thu

    return Wrap(
      spacing: 8,
      children: days.map((day) {
        final isSelected = day == _selectedDay;
        return ChoiceChip(
          label: Text(TimeUtils.getDayNameShort(day)),
          selected: isSelected,
          onSelected: (_) => setState(() => _selectedDay = day),
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSlotPresets() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: RoutineSlot.defaultSlots.length,
        itemBuilder: (context, index) {
          final slot = RoutineSlot.defaultSlots[index];
          final isSelected = _startHour == slot.startHour &&
              _startMinute == slot.startMinute &&
              _endHour == slot.endHour &&
              _endMinute == slot.endMinute;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() {
                _startHour = slot.startHour;
                _startMinute = slot.startMinute;
                _endHour = slot.endHour;
                _endMinute = slot.endMinute;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textTertiaryDark.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  slot.timeRange,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? AppColors.primary : null,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required int hour,
    required int minute,
    required Function(int, int) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: hour, minute: minute),
        );
        if (picked != null) {
          onChanged(picked.hour, picked.minute);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceVariantDark
              : AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 18),
            const SizedBox(width: 8),
            Text(
              TimeUtils.formatTime(hour, minute),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _onSave() {
    final courseCode = _courseCodeController.text.trim();
    if (courseCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course code is required')),
      );
      return;
    }

    final session = widget.session != null
        ? widget.session!.copyWith(
            courseCode: courseCode,
            section: _sectionController.text.trim(),
            group: _group,
            instructor: _instructorController.text.trim().isEmpty
                ? null
                : _instructorController.text.trim(),
            roomType: _roomType,
            roomNumber: _roomNumberController.text.trim(),
            dayOfWeek: _selectedDay,
            startHour: _startHour,
            startMinute: _startMinute,
            endHour: _endHour,
            endMinute: _endMinute,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          )
        : ClassSession.create(
            courseCode: courseCode,
            section: _sectionController.text.trim(),
            group: _group,
            instructor: _instructorController.text.trim().isEmpty
                ? null
                : _instructorController.text.trim(),
            roomType: _roomType,
            roomNumber: _roomNumberController.text.trim(),
            dayOfWeek: _selectedDay,
            startHour: _startHour,
            startMinute: _startMinute,
            endHour: _endHour,
            endMinute: _endMinute,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );

    widget.onSave(session);
    Navigator.of(context).pop();
  }
}
