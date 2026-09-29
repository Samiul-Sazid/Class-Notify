# 🎓 Class Routine Notifier (Class-Notify)

A professional, production-grade Flutter application built for university students that intelligently parses physical class timetable images using **Google Gemini Vision AI**, organizes schedules across an academic week, and schedules precise phone alarms and notifications before every class.

---

## ✨ Features

- 📸 **AI Routine Scanner**: Snap a photo or upload an image of your class routine. Gemini 2.0 Flash Vision AI extracts tabular timetable data directly into structured sessions.
- 🧪 **Offline Demo Routine**: One-tap sample schedule import to test the entire routine, countdown, and alarm flow without requiring an API key.
- ⏰ **Smart Alarms & Notifications**: Exact weekly recurring alarms configured via `flutter_local_notifications` with timezone-aware scheduling (`Asia/Dhaka` UTC+6) and customizable reminder lead times (5, 10, 15, or 30 minutes before class).
- 📅 **Today's Dashboard**:
  - Live greeting & dynamic countdown to next class.
  - Active session spotlight card with pulsing `LIVE` badge.
  - Chronological daily timeline with past, active, and upcoming indicators.
- 🗓️ **Weekly Timetable Grid**:
  - Saturday through Thursday day selector tabs with class count badges.
  - 75-minute standard university time blocks.
  - Swipe-to-delete gesture and individual class notification toggles.
- ✏️ **Manual Class Editor**: Full bottom-sheet modal form to add or edit classes with custom color swatches, room types, sections, groups, and notes.
- 🎨 **Glassmorphism Design System**: Dark/light theme support, frosted glass aesthetics, Google Fonts (Inter & Poppins), and harmonious color coding for course families.
- 💾 **Offline-First Persistence**: Lightweight and instant data storage using `shared_preferences`.

---

## 🏛️ Architecture

Built following **Clean Architecture** principles and the **MVVM (Model-View-ViewModel)** pattern:

```text
lib/
├── main.dart                                         # Bootstrap, manual DI, MaterialApp
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                           # Semantic palette & course color families
│   │   └── app_theme.dart                            # Material 3 light/dark ThemeData
│   ├── services/
│   │   ├── notification_service.dart                 # Exact alarms & recurring weekly notifications
│   │   └── storage_service.dart                      # SharedPreferences JSON persistence
│   └── utils/
│       └── time_utils.dart                           # 24h/12h parsing, countdowns, active detector
├── data/
│   ├── models/
│   │   ├── class_session.dart                        # Core timetable session model
│   │   ├── routine_slot.dart                         # 75-minute academic slot specifications
│   │   └── user_settings.dart                        # User preferences (lead time, API key, theme)
│   └── repositories/
│       └── routine_repository.dart                   # Single source of truth (ChangeNotifier)
├── domain/
│   └── services/
│       ├── routine_parser_service.dart               # Parser abstraction interface
│       ├── gemini_vision_parser.dart                 # Gemini 2.0 Flash REST vision client
│       └── sample_routine_parser.dart                # Offline instant sample schedule
└── ui/
    ├── core/
    │   ├── glass_card.dart                           # Frosted glass card UI atom
    │   └── class_session_card.dart                   # Class card with swipe dismissal & badges
    └── features/
        ├── home/views/main_navigation_screen.dart    # 4-tab smooth PageView shell
        ├── today/                                    # Today dashboard & live timer
        ├── timetable/                                # Weekly timetable & edit sheet
        ├── scanner/                                  # Photo capture, AI extract & review
        └── settings/                                 # Alarms, theme, API key settings
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.24+ recommended)
- Android Studio / VS Code with Flutter extension
- An Android device or emulator (Android 8.0+ / API 26+)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Samiul-Sazid/Class-Notify.git
   cd Class-Notify
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   - On an Android device or emulator:
     ```bash
     flutter run
     ```
   - In Chrome / Web preview:
     ```bash
     flutter run -d chrome
     ```

---

## 🔑 Setting Up Gemini Vision AI

To extract routines directly from custom photos using Google's Gemini Vision API:

1. Obtain a free API key from [Google AI Studio](https://aistudio.google.com/apikey).
2. Open the app, go to the **Settings** tab.
3. Paste your key in the **Gemini API Key** field.
4. Go to **Scan** tab, take a photo or select an image of your timetable, and tap **Extract Schedule**.

*(Note: You can always use the built-in **"Try with Sample Routine"** button without an API key!)*

---

## 🧪 Testing

The project includes unit and widget test suites covering data models, time utilities, parsers, repositories, and UI widgets:

```bash
# Run all tests
flutter test

# Run static analysis
dart analyze
```

---

## 📦 Android Permissions Configured

- `android.permission.POST_NOTIFICATIONS`: To show class reminder notifications.
- `android.permission.SCHEDULE_EXACT_ALARM`: For exact, battery-efficient alarm triggering.
- `android.permission.USE_EXACT_ALARM`: For Android 13+ exact alarms.
- `android.permission.RECEIVE_BOOT_COMPLETED`: Reschedules all alarms automatically after phone reboot.
- `android.permission.VIBRATE`: Haptic alarm vibration.
- `android.permission.CAMERA`: Take photos of physical routine printouts.

---

## 📄 License

This project is licensed under the MIT License.