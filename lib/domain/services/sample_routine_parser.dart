import '../../data/models/class_session.dart';
import 'routine_parser_service.dart';

/// Sample parser that returns a hardcoded schedule matching the user's
/// provided routine image (2022-2023 academic year).
///
/// This enables:
/// 1. Immediate testing without a Gemini API key
/// 2. Offline demonstration of the full import workflow
/// 3. Unit testing of the review → import → notification pipeline
///
/// ## Flutter Learning Note:
/// Having a "fake" or "mock" implementation of a service is a common
/// development pattern. It lets you build and test the entire UI without
/// needing the real backend/API to be ready. Once the real parser works,
/// you simply swap the implementation — no UI code changes needed.
class SampleRoutineParser implements RoutineParserService {
  @override
  Future<List<ClassSession>> parseRoutineImage(
    String imagePath, {
    String? apiKey,
  }) async {
    // Simulate a brief processing delay for realistic UX
    await Future.delayed(const Duration(seconds: 2));

    return _sampleSchedule();
  }

  /// Returns the exact schedule from the user's routine image.
  static List<ClassSession> _sampleSchedule() {
    return [
      // ─── SATURDAY ───
      ClassSession.create(
        courseCode: 'PROG 302',
        section: 'MM',
        group: 'G-1',
        roomType: 'Lab Room',
        roomNumber: '2701',
        dayOfWeek: 6, // Saturday
        startHour: 10,
        startMinute: 15,
        endHour: 11,
        endMinute: 30,
      ),
      ClassSession.create(
        courseCode: 'PROG 302',
        section: 'MM',
        group: 'G-2',
        roomType: 'Lab Room',
        roomNumber: '2701',
        dayOfWeek: 6,
        startHour: 11,
        startMinute: 30,
        endHour: 12,
        endMinute: 45,
      ),
      ClassSession.create(
        courseCode: 'PROG 301',
        section: 'MM',
        instructor: null,
        roomType: 'Lecture Room',
        roomNumber: '4002',
        dayOfWeek: 6,
        startHour: 12,
        startMinute: 45,
        endHour: 14,
        endMinute: 15,
        note: 'Including 15 mins prayer break',
      ),

      // ─── SUNDAY ───
      ClassSession.create(
        courseCode: 'IRE 215',
        section: 'SE',
        roomType: 'Lecture Room',
        roomNumber: '1002',
        dayOfWeek: 7, // Sunday
        startHour: 9,
        startMinute: 0,
        endHour: 10,
        endMinute: 15,
      ),
      ClassSession.create(
        courseCode: 'IRE 212',
        section: 'SCD',
        group: 'G-1',
        roomType: 'Lab Room',
        roomNumber: 'IOT LAB',
        dayOfWeek: 7,
        startHour: 10,
        startMinute: 15,
        endHour: 11,
        endMinute: 30,
      ),
      ClassSession.create(
        courseCode: 'IRE 216',
        section: 'SE',
        group: 'G-2',
        roomType: 'Lab Room',
        roomNumber: '5701',
        dayOfWeek: 7,
        startHour: 10,
        startMinute: 15,
        endHour: 11,
        endMinute: 30,
      ),
      ClassSession.create(
        courseCode: 'MATH 217',
        section: '',
        instructor: 'Sujan Sir',
        roomType: 'Lecture Room',
        roomNumber: '2002',
        dayOfWeek: 7,
        startHour: 11,
        startMinute: 30,
        endHour: 12,
        endMinute: 45,
      ),
      ClassSession.create(
        courseCode: 'PROG 301',
        section: 'MM',
        roomType: 'Tutorial Room',
        roomNumber: '1002',
        dayOfWeek: 7,
        startHour: 12,
        startMinute: 45,
        endHour: 14,
        endMinute: 15,
        note: 'Including 15 mins prayer break',
      ),
      ClassSession.create(
        courseCode: 'IRE 212',
        section: 'SCD',
        group: 'G-2',
        roomType: 'Lab Room',
        roomNumber: 'IOT LAB',
        dayOfWeek: 7,
        startHour: 14,
        startMinute: 15,
        endHour: 15,
        endMinute: 30,
      ),

      // ─── MONDAY ───
      ClassSession.create(
        courseCode: 'IRE 216',
        section: 'SE',
        group: 'G-1',
        roomType: 'Lab Room',
        roomNumber: '4701',
        dayOfWeek: 1, // Monday
        startHour: 9,
        startMinute: 0,
        endHour: 10,
        endMinute: 15,
      ),
      ClassSession.create(
        courseCode: 'CSE 219',
        section: 'MTA',
        roomType: 'Lecture Room',
        roomNumber: '4002',
        dayOfWeek: 1,
        startHour: 10,
        startMinute: 15,
        endHour: 11,
        endMinute: 30,
      ),
      ClassSession.create(
        courseCode: 'CSE 211',
        section: 'SCD',
        roomType: 'Lecture Room',
        roomNumber: '1002',
        dayOfWeek: 1,
        startHour: 11,
        startMinute: 30,
        endHour: 12,
        endMinute: 45,
      ),
      ClassSession.create(
        courseCode: 'MATH 217',
        section: '',
        instructor: 'Sujan Sir',
        roomType: 'Tutorial Room',
        roomNumber: '2002',
        dayOfWeek: 1,
        startHour: 12,
        startMinute: 45,
        endHour: 14,
        endMinute: 15,
        note: 'Including 15 mins prayer break',
      ),

      // ─── TUESDAY ───
      ClassSession.create(
        courseCode: 'CSE 219',
        section: 'MTA',
        roomType: 'Tutorial Room',
        roomNumber: '1002',
        dayOfWeek: 2, // Tuesday
        startHour: 9,
        startMinute: 0,
        endHour: 10,
        endMinute: 15,
      ),
      ClassSession.create(
        courseCode: 'IRE 215',
        section: 'SE',
        roomType: 'Tutorial Room',
        roomNumber: '1002',
        dayOfWeek: 2,
        startHour: 10,
        startMinute: 15,
        endHour: 11,
        endMinute: 30,
      ),
      ClassSession.create(
        courseCode: 'CSE 211',
        section: 'SCD',
        roomType: 'Tutorial Room',
        roomNumber: '1002',
        dayOfWeek: 2,
        startHour: 12,
        startMinute: 45,
        endHour: 14,
        endMinute: 15,
        note: 'Including 15 mins prayer break',
      ),
    ];
  }
}
