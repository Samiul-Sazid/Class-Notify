import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/models/class_session.dart';
import '../../../../data/repositories/routine_repository.dart';
import '../../../../domain/services/routine_parser_service.dart';
import '../../../../domain/services/gemini_vision_parser.dart';
import '../../../../domain/services/sample_routine_parser.dart';

/// Status of the parsing operation.
enum ParseStatus { idle, loading, success, error }

/// ViewModel for the routine scanner/upload screen.
///
/// ## Flutter Learning Note:
/// This ViewModel demonstrates a **state machine** pattern:
/// idle → loading → success/error
///
/// The UI observes `parseStatus` and renders different widgets for each state:
/// - idle: show upload buttons
/// - loading: show progress spinner
/// - success: show extracted sessions for review
/// - error: show error message with retry option
class ScannerViewModel extends ChangeNotifier {
  final RoutineRepository repository;
  final ImagePicker _imagePicker = ImagePicker();

  // Parsers
  final GeminiVisionParser _geminiParser = GeminiVisionParser();
  final SampleRoutineParser _sampleParser = SampleRoutineParser();

  // State
  ParseStatus _parseStatus = ParseStatus.idle;
  String? _selectedImagePath;
  List<ClassSession> _extractedSessions = [];
  String? _errorMessage;
  String _statusMessage = '';

  ScannerViewModel({required this.repository});

  // --- Exposed State ---

  ParseStatus get parseStatus => _parseStatus;
  String? get selectedImagePath => _selectedImagePath;
  List<ClassSession> get extractedSessions => List.unmodifiable(_extractedSessions);
  String? get errorMessage => _errorMessage;
  String get statusMessage => _statusMessage;

  /// Whether a Gemini API key is configured.
  bool get hasApiKey =>
      repository.settings.geminiApiKey != null &&
      repository.settings.geminiApiKey!.isNotEmpty;

  // --- Actions ---

  /// Pick an image from the camera or gallery.
  Future<void> pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (picked != null) {
        _selectedImagePath = picked.path;
        _parseStatus = ParseStatus.idle;
        _extractedSessions = [];
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to pick image: $e';
      notifyListeners();
    }
  }

  /// Parse the selected image using Gemini Vision AI.
  Future<void> parseWithGemini() async {
    if (_selectedImagePath == null) {
      _errorMessage = 'Please select an image first.';
      notifyListeners();
      return;
    }

    final apiKey = repository.settings.geminiApiKey;

    await _parseWith(_geminiParser, apiKey: apiKey);
  }

  /// Parse using the built-in sample parser (for testing/demo).
  Future<void> parseWithSample() async {
    _selectedImagePath = 'sample'; // Placeholder path
    await _parseWith(_sampleParser);
  }

  /// Core parsing logic shared by both parser strategies.
  Future<void> _parseWith(
    RoutineParserService parser, {
    String? apiKey,
  }) async {
    _parseStatus = ParseStatus.loading;
    _statusMessage = 'Analyzing image...';
    _errorMessage = null;
    notifyListeners();

    try {
      _statusMessage = 'Extracting class schedule...';
      notifyListeners();

      final sessions = await parser.parseRoutineImage(
        _selectedImagePath ?? '',
        apiKey: apiKey,
      );

      _extractedSessions = sessions;
      _parseStatus = ParseStatus.success;
      _statusMessage = 'Found ${sessions.length} classes!';
    } catch (e) {
      _parseStatus = ParseStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _statusMessage = '';
    }

    notifyListeners();
  }

  /// Import the extracted sessions into the timetable.
  Future<void> importExtractedSessions({bool clearExisting = false}) async {
    if (_extractedSessions.isEmpty) return;

    await repository.importSessions(
      _extractedSessions,
      clearExisting: clearExisting,
    );

    // Reset scanner state
    reset();
  }

  /// Remove a specific extracted session (before importing).
  void removeExtractedSession(int index) {
    if (index >= 0 && index < _extractedSessions.length) {
      _extractedSessions.removeAt(index);
      notifyListeners();
    }
  }

  /// Update a specific extracted session (before importing).
  void updateExtractedSession(int index, ClassSession updated) {
    if (index >= 0 && index < _extractedSessions.length) {
      _extractedSessions[index] = updated;
      notifyListeners();
    }
  }

  /// Reset the scanner to initial state.
  void reset() {
    _parseStatus = ParseStatus.idle;
    _selectedImagePath = null;
    _extractedSessions = [];
    _errorMessage = null;
    _statusMessage = '';
    notifyListeners();
  }
}
