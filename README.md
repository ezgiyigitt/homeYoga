# Home Yoga

<p align="center">
  <img src="assets/images/app_icon.png" alt="Home Yoga app icon" width="180" />
</p>

<p align="center">
  <img src="assets/images/rotate_yoga_bg.jpg" alt="Home Yoga wellness studio" width="720" />
</p>

A modern Flutter wellness app designed to help users build sustainable yoga, pilates, mobility, and mindfulness habits through personalized daily practice plans, guided sessions, and progress tracking.

## Overview

Home Yoga blends coaching, habit-building, and movement data into a calm, guided wellness experience. The app is built to support users from beginner to intermediate levels with structured daily routines, posture-aware guidance, and motivational tracking.

## Highlights

- Personalized daily practice plans
- Yoga and pilates workout library
- AI wellness coach experience
- Session progress and achievement tracking
- Local-first and Supabase-backed data flow
- Internationalized UI for multi-language support
- Mobile-first design optimized for calm, focused practice

## Tech Stack

- Flutter & Dart
- Riverpod for state management
- Go Router for navigation
- Supabase for backend data and auth
- Google Gemini / OpenRouter for AI coaching
- Video player and media playback utilities
- SharedPreferences and local persistence
- Material Design system with custom wellness theming

## Features

### Personalized fitness and wellness journey
The experience is centered around user goals, available time, equipment limits, and progress history. Daily recommendations adapt to the user profile and training rhythm.

### Guided practice library
The app includes structured yoga and pilates content designed around body awareness, mobility, strength, recovery, and balance.

### AI coach
A conversational wellness coach provides supportive guidance and encouragement using AI-powered prompts and coaching flows.

### Progress and motivation
Users can track consistency, practice milestones, and overall engagement with a lightweight gamified workflow.

## Repository Structure

```text
.
├── android/                # Android configuration
├── ios/                    # iOS configuration
├── lib/                    # Flutter application source
│   ├── app/                # App bootstrap and configuration
│   ├── core/               # constants, config, theme, localization
│   ├── data/               # repositories and data sources
│   ├── domain/             # entities, use cases, business logic
│   └── presentation/       # screens, widgets, features
├── assets/                 # app images and media
├── supabase/               # schema and DB migration scripts
├── test/                   # project tests
├── analysis_options.yaml   # linting config
├── pubspec.yaml            # Flutter dependencies
├── README.md               # project documentation
├── l10n.yaml               # localization config
└── ...
```

## Getting Started

### Prerequisites

- Flutter SDK 3.5+
- Dart SDK compatible with your Flutter version
- Android Studio / Xcode / VS Code with Flutter extension
- Supabase project access
- Gemini or OpenRouter API key for AI features

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

For a specific device or simulator:

```bash
flutter devices
flutter run -d <device-id>
```

## Configuration

### Supabase
The app expects Supabase credentials in:

- `lib/core/constants/supabase_config.dart`

Update the project URL and anon key with your real values before running the app against your own backend.

### AI API keys
The project supports API keys via `--dart-define`:

```bash
flutter run \
  --dart-define=GEMINI_API_KEY=your_gemini_key \
  --dart-define=OPENROUTER_API_KEY=your_openrouter_key
```

If you use the project with a local or mock configuration, make sure the app defaults are updated in the relevant constants file.

## Verification

This repository was validated locally with:

```bash
flutter analyze
flutter test
```

Current result:

- `flutter analyze` → no issues found
- `flutter test` → `00:10 +2: All tests passed!`

## Local Development Notes

- This repository includes generated localization files and platform config.
- App assets are under `assets/images/` and `assets/videos/`.
- The backend and exercise data are structured for Supabase-driven content management.

## Contributing

Contributions are welcome. If you want to improve the app, please:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Open a pull request with a clear description

## Project Status

The app is actively structured as a wellness-focused mobile product with a backend, coaching layer, and personalized fitness flow. It is ready for extension, onboarding improvements, and deployment packaging.

## Notes

This project currently does not declare a separate license file in the repository, so license status should be confirmed before public distribution or commercial deployment.
