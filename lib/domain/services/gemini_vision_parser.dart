import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../data/models/class_session.dart';
import '../../core/utils/time_utils.dart';
import 'routine_parser_service.dart';

/// Parses class routine images using Google's Gemini Vision AI.
///
/// ## Flutter Learning Note:
/// This is a real-world example of calling a REST API from Flutter:
/// 1. Read the image file as bytes
/// 2. Base64-encode it (required for inline image data in Gemini API)
/// 3. Build the JSON request body with a carefully-engineered prompt
/// 4. Send an HTTP POST request
/// 5. Parse the JSON response
///
/// The prompt engineering is critical — it tells the AI EXACTLY what format
/// to return, matching our ClassSession model fields.
class GeminiVisionParser implements RoutineParserService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  @override
  Future<List<ClassSession>> parseRoutineImage(
    String imagePath, {
    String? apiKey,
  }) async {
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw Exception(
        'Gemini API key is required. Get a free key from '
        'https://aistudio.google.com/apikey',
      );
    }

    // Step 1: Read the image file and encode as base64
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('Image file not found: $imagePath');
    }

    final imageBytes = await file.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    // Determine MIME type from extension
    final extension = imagePath.split('.').last.toLowerCase();
    final mimeType = switch (extension) {
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg', // Default fallback
    };

    // Step 2: Build the API request with engineered prompt
    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {
              'inlineData': {
                'mimeType': mimeType,
                'data': base64Image,
              },
            },
            {
              'text': _buildPrompt(),
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.1, // Low temperature for precise extraction
        'maxOutputTokens': 4096,
      },
    });

    // Step 3: Send HTTP POST request to Gemini API
    final url = Uri.parse('$_baseUrl?key=$apiKey');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: requestBody,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        final message =
            errorBody['error']?['message'] ?? 'Unknown API error';
        throw Exception('Gemini API error (${response.statusCode}): $message');
      }

      // Step 4: Parse the response
      final responseBody = jsonDecode(response.body);
      final textContent = responseBody['candidates']?[0]?['content']
          ?['parts']?[0]?['text'] as String?;

      if (textContent == null || textContent.isEmpty) {
        throw Exception('Empty response from Gemini API');
      }

      return _parseResponseJson(textContent);
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// The carefully-engineered prompt that extracts structured schedule data.
  String _buildPrompt() {
    return '''
You are analyzing a university class routine/timetable image.
Extract ALL classes into this exact JSON array format:

[
  {
    "course_code": "PROG 302",
    "section": "MM",
    "group": "G-1",
    "instructor": null,
    "room_type": "Lab Room",
    "room_number": "2701",
    "day": "Saturday",
    "start_time": "10:15",
    "end_time": "11:30",
    "note": null
  }
]

Rules:
- Days may include: Saturday, Sunday, Monday, Tuesday, Wednesday, Thursday, Friday
- "section" is the abbreviation in parentheses like (MM), (SE), (SCD), (MTA). If parentheses contain a person's name (like "Sujan Sir"), put it in "instructor" instead and set "section" to empty string.
- "instructor" is a person's name if found in parentheses like (Sujan Sir). Set null if no instructor name is found.
- "group" is G-1, G-2 etc. Set null if absent.
- "room_type" is one of: "Lab Room", "Lecture Room", "Tutorial Room", or the raw prefix text before the room number/dash.
- "room_number" is the number/name after the dash or hyphen (e.g., "2701", "IOT LAB", "4002", "4701", "5701").
- Parse times from column headers. Convert to 24-hour HH:MM format. If a time like "02:15" appears ambiguous, interpret it as 14:15 (PM) in the context of an afternoon university schedule.
- Skip empty cells entirely — only include cells that have class information.
- Include any special annotations like "Including 15 mins prayer break" in the "note" field.
- For each filled cell in the timetable grid, produce exactly one JSON object.

Return ONLY the raw JSON array. No markdown code fences, no explanation, no extra text.
''';
  }

  /// Parses the raw text response from Gemini into a list of ClassSessions.
  List<ClassSession> _parseResponseJson(String rawText) {
    // Clean up: remove markdown fences if present
    String cleaned = rawText.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();

    // Parse JSON
    List<dynamic> jsonList;
    try {
      jsonList = jsonDecode(cleaned) as List<dynamic>;
    } catch (e) {
      throw Exception(
        'Failed to parse AI response as JSON. '
        'The image may be unclear or not a valid timetable.',
      );
    }

    // Convert each JSON object to a ClassSession
    final sessions = <ClassSession>[];
    for (final item in jsonList) {
      try {
        final map = item as Map<String, dynamic>;
        final session = _mapToClassSession(map);
        if (session != null) sessions.add(session);
      } catch (e) {
        debugPrint('Skipping malformed entry: $item — $e');
      }
    }

    if (sessions.isEmpty) {
      throw Exception(
        'No classes could be extracted from the image. '
        'Please try with a clearer photo.',
      );
    }

    return sessions;
  }

  /// Maps a single JSON object from the AI response to a ClassSession.
  ClassSession? _mapToClassSession(Map<String, dynamic> map) {
    final courseCode = (map['course_code'] as String?)?.trim();
    if (courseCode == null || courseCode.isEmpty) return null;

    final dayName = (map['day'] as String?)?.trim() ?? '';
    final dayOfWeek = TimeUtils.dayNameToWeekday(dayName);
    if (dayOfWeek == null) return null;

    // Parse start and end times
    final startTimeStr = (map['start_time'] as String?)?.trim() ?? '';
    final endTimeStr = (map['end_time'] as String?)?.trim() ?? '';
    final startTime = TimeUtils.parseTimeString(startTimeStr);
    final endTime = TimeUtils.parseTimeString(endTimeStr);
    if (startTime == null || endTime == null) return null;

    return ClassSession.create(
      courseCode: courseCode,
      section: (map['section'] as String?)?.trim() ?? '',
      group: (map['group'] as String?)?.trim(),
      instructor: (map['instructor'] as String?)?.trim(),
      roomType: (map['room_type'] as String?)?.trim() ?? 'Lecture Room',
      roomNumber: (map['room_number'] as String?)?.trim() ?? '',
      dayOfWeek: dayOfWeek,
      startHour: startTime.hour,
      startMinute: startTime.minute,
      endHour: endTime.hour,
      endMinute: endTime.minute,
      note: (map['note'] as String?)?.trim(),
    );
  }
}
