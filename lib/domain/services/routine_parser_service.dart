import '../../data/models/class_session.dart';

/// Abstract contract for timetable image parsers.
///
/// ## Flutter Learning Note:
/// This is the **Strategy Pattern** — we define an interface (abstract class)
/// and provide multiple implementations:
/// - GeminiVisionParser: uses AI to extract schedule from photos
/// - SampleRoutineParser: returns a hardcoded demo schedule
///
/// The ScannerViewModel doesn't need to know WHICH parser it's using — it
/// just calls `parseRoutineImage()`. This makes the system extensible:
/// you can add a new parser (e.g., on-device ML Kit OCR) without changing
/// any existing code. This is the Open/Closed Principle in action.
abstract class RoutineParserService {
  /// Parses a routine image and returns a list of extracted ClassSessions.
  ///
  /// [imagePath] is the local file path to the image.
  /// [apiKey] is optional and used by AI-based parsers (e.g., Gemini API key).
  ///
  /// Throws an exception if parsing fails.
  Future<List<ClassSession>> parseRoutineImage(
    String imagePath, {
    String? apiKey,
  });
}
