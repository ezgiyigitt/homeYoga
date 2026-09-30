import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_providers.dart';

/// Which days of the week a practice reminder should fire on.
/// Index 0 = Monday … 6 = Sunday, matching `DateTime.weekday - 1`.
const List<String> kWeekdayInitials = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

/// User preferences that are not part of the fitness profile: reminders and
/// audio. Stored locally, since they describe this device rather than the
/// account.
@immutable
class AppSettings {
  // ── Reminders ────────────────────────────────────────
  final bool remindersEnabled;

  /// Minutes from midnight, so the whole preference is one int.
  final int reminderMinuteOfDay;

  /// Seven flags, Monday first.
  final List<bool> reminderDays;

  /// Nudge on a day that has gone by with nothing recorded.
  final bool missedDayNudge;

  // ── Audio ────────────────────────────────────────────
  final bool voiceGuideEnabled;
  final bool soundEffectsEnabled;
  final bool autoplayVideo;

  /// 0.0 … 1.0, applied to the workout player.
  final double voiceVolume;

  const AppSettings({
    this.remindersEnabled = false,
    this.reminderMinuteOfDay = 8 * 60,
    this.reminderDays = const [true, true, true, true, true, true, true],
    this.missedDayNudge = true,
    this.voiceGuideEnabled = true,
    this.soundEffectsEnabled = true,
    this.autoplayVideo = true,
    this.voiceVolume = 0.8,
  });

  TimeOfDay get reminderTime => TimeOfDay(
        hour: reminderMinuteOfDay ~/ 60,
        minute: reminderMinuteOfDay % 60,
      );

  /// "08:00" — a stable, locale-independent rendering for the settings row.
  String get reminderTimeLabel {
    final h = (reminderMinuteOfDay ~/ 60).toString().padLeft(2, '0');
    final m = (reminderMinuteOfDay % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// "Every day", "Weekdays", "Mon, Wed, Fri"…
  String get reminderDaysLabel {
    final selected = <int>[
      for (var i = 0; i < reminderDays.length; i++)
        if (reminderDays[i]) i,
    ];
    if (selected.isEmpty) return 'No days';
    if (selected.length == 7) return 'Every day';
    if (selected.length == 5 && selected.every((i) => i < 5)) return 'Weekdays';
    if (selected.length == 2 && selected.every((i) => i >= 5)) return 'Weekends';
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return selected.map((i) => names[i]).join(', ');
  }

  AppSettings copyWith({
    bool? remindersEnabled,
    int? reminderMinuteOfDay,
    List<bool>? reminderDays,
    bool? missedDayNudge,
    bool? voiceGuideEnabled,
    bool? soundEffectsEnabled,
    bool? autoplayVideo,
    double? voiceVolume,
  }) {
    return AppSettings(
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderMinuteOfDay: reminderMinuteOfDay ?? this.reminderMinuteOfDay,
      reminderDays: reminderDays ?? this.reminderDays,
      missedDayNudge: missedDayNudge ?? this.missedDayNudge,
      voiceGuideEnabled: voiceGuideEnabled ?? this.voiceGuideEnabled,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      autoplayVideo: autoplayVideo ?? this.autoplayVideo,
      voiceVolume: voiceVolume ?? this.voiceVolume,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;

  static const _kRemindersEnabled = 'hy_set_reminders_on';
  static const _kReminderMinute = 'hy_set_reminder_minute';
  static const _kReminderDays = 'hy_set_reminder_days';
  static const _kMissedNudge = 'hy_set_missed_nudge';
  static const _kVoiceGuide = 'hy_set_voice_guide';
  static const _kSoundEffects = 'hy_set_sound_fx';
  static const _kAutoplay = 'hy_set_autoplay';
  static const _kVoiceVolume = 'hy_set_voice_volume';

  SettingsNotifier(this._prefs) : super(_load(_prefs));

  static AppSettings _load(SharedPreferences p) {
    final raw = p.getString(_kReminderDays);
    final days = raw != null && raw.length == 7
        ? [for (final c in raw.split('')) c == '1']
        : const [true, true, true, true, true, true, true];

    return AppSettings(
      remindersEnabled: p.getBool(_kRemindersEnabled) ?? false,
      reminderMinuteOfDay: p.getInt(_kReminderMinute) ?? 8 * 60,
      reminderDays: days,
      missedDayNudge: p.getBool(_kMissedNudge) ?? true,
      voiceGuideEnabled: p.getBool(_kVoiceGuide) ?? true,
      soundEffectsEnabled: p.getBool(_kSoundEffects) ?? true,
      autoplayVideo: p.getBool(_kAutoplay) ?? true,
      voiceVolume: p.getDouble(_kVoiceVolume) ?? 0.8,
    );
  }

  void _write(AppSettings s) {
    state = s;
    _prefs.setBool(_kRemindersEnabled, s.remindersEnabled);
    _prefs.setInt(_kReminderMinute, s.reminderMinuteOfDay);
    _prefs.setString(
      _kReminderDays,
      s.reminderDays.map((d) => d ? '1' : '0').join(),
    );
    _prefs.setBool(_kMissedNudge, s.missedDayNudge);
    _prefs.setBool(_kVoiceGuide, s.voiceGuideEnabled);
    _prefs.setBool(_kSoundEffects, s.soundEffectsEnabled);
    _prefs.setBool(_kAutoplay, s.autoplayVideo);
    _prefs.setDouble(_kVoiceVolume, s.voiceVolume);
  }

  void setRemindersEnabled(bool value) =>
      _write(state.copyWith(remindersEnabled: value));

  void setReminderTime(TimeOfDay time) =>
      _write(state.copyWith(reminderMinuteOfDay: time.hour * 60 + time.minute));

  void toggleReminderDay(int index) {
    final days = [...state.reminderDays];
    days[index] = !days[index];
    _write(state.copyWith(reminderDays: days));
  }

  void setMissedDayNudge(bool value) =>
      _write(state.copyWith(missedDayNudge: value));

  void setVoiceGuideEnabled(bool value) =>
      _write(state.copyWith(voiceGuideEnabled: value));

  void setSoundEffectsEnabled(bool value) =>
      _write(state.copyWith(soundEffectsEnabled: value));

  void setAutoplayVideo(bool value) =>
      _write(state.copyWith(autoplayVideo: value));

  void setVoiceVolume(double value) =>
      _write(state.copyWith(voiceVolume: value.clamp(0.0, 1.0)));
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.watch(sharedPreferencesProvider));
});
