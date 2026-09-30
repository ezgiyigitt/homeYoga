import '../constants/app_constants.dart';
import 'date_key.dart';

/// Simulates one week's pot state day by day and returns a single
/// signed level in `[-7, 7]`:
///
///  * a practiced day advances the level by +1 (toward the growing
///    side, capped at +7 — [AppConstants.plantSpriteFrameCount]),
///  * a missed day (no entry, and only once tracking has actually
///    started — see [earliestLoggedDate]) advances it by -1 (toward
///    the wilting side, capped at -7),
///  * an explicit "off" day leaves the level untouched — declaring a
///    rest day is never punished,
///  * today itself (if not yet logged) and any day still in the
///    future are left untouched too, since they haven't happened yet.
///
/// The sign says which spritesheet to use (>=0 → growing, <0 →
/// wilting) and the magnitude (1..7) says which frame. Level 0 (a
/// week that hasn't started, or where nothing has happened yet) shows
/// growing frame 1 — the baseline "just planted" sprite.
///
/// Each week restarts at 0 on its own Monday — this is deliberately a
/// *weekly* pot, not one continuous year-long counter, so a rough
/// week doesn't permanently scar every future card. Crucially, this
/// day-by-day walk is also what makes recovery gradual: while the
/// level is still negative, a practiced day only reduces the wilting
/// *severity* by one frame — it takes as many good days to climb back
/// out of a wilted state as it took days to wilt it, and the sprite
/// never jumps straight from "very wilted" to "fully green".
int computeWeekPlantLevel({
  required DateTime weekStart,
  required Map<String, String> dailyLog,
  required DateTime today,
}) {
  final trackingStart = earliestLoggedDate(dailyLog);
  int level = 0;

  for (int i = 0; i < 7; i++) {
    final day = weekStart.add(Duration(days: i));
    if (day.isAfter(today)) break; // this week hasn't reached that day yet

    final status = dailyLog[dateKey(day)];
    final cap = AppConstants.plantSpriteFrameCount;

    if (status == AppConstants.dayStatusDone) {
      level = (level + 1).clamp(-cap, cap);
    } else if (status == AppConstants.dayStatusOff) {
      // Declared rest day — no change either way.
    } else if (day.isBefore(today) &&
        trackingStart != null &&
        !day.isBefore(trackingStart)) {
      // Only a *tracked* past day with nothing recorded counts as
      // missed — a brand-new user's pre-signup history is never
      // retroactively wilted (see MonthlyProgressBar for the same
      // reasoning applied to the monthly bar).
      level = (level - 1).clamp(-cap, cap);
    }
    // Otherwise: today with no entry yet, or before tracking started
    // — left untouched.
  }

  return level;
}

/// Which spritesheet + frame a [computeWeekPlantLevel] result maps to.
class PlantSpriteState {
  final String assetPath;
  final int frameIndex; // 0-based, into AppConstants.plantSpriteFrameCount

  const PlantSpriteState({required this.assetPath, required this.frameIndex});

  factory PlantSpriteState.fromLevel(int level) {
    final cap = AppConstants.plantSpriteFrameCount;
    if (level >= 0) {
      final frame = level.clamp(1, cap); // 0 also renders as frame 1 (baseline)
      return PlantSpriteState(assetPath: AppConstants.plantGrowingAsset, frameIndex: frame - 1);
    }
    final frame = (-level).clamp(1, cap);
    return PlantSpriteState(assetPath: AppConstants.plantWiltingAsset, frameIndex: frame - 1);
  }
}
