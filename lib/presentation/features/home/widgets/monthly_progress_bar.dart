import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_key.dart';

/// What a single calendar day means for the month view.
enum _DayState {
  /// A practice was completed — written by `completePractice`.
  done,

  /// Declared a rest day — written by `MarkDayOffUseCase`.
  off,

  /// In the past, inside the tracked window, with nothing recorded.
  /// Derived rather than stored, so it stays correct even when the user
  /// never opens the app on the day that lapses.
  missed,

  /// Today, still undecided.
  today,

  /// Later this month — hasn't happened yet.
  future,

  /// Before the user's first recorded day. Not their fault, so it is
  /// never drawn as a miss.
  untracked,
}

/// The monthly progress card pinned at the very top of Home.
///
/// One column per real calendar day, each drawn from that day's actual
/// entry in the daily log — so the card shows what the user has done,
/// not merely where the month currently is. A practised day stands at
/// full height in brand green and a missed day at the same height in
/// red, so the pattern reads at a glance; a declared rest day sits
/// lower in sage, and days still ahead stay a faint track. Today is
/// outlined rather than filled while it is still undecided, which is
/// what makes the card read as live.
///
/// Tapping the card unfolds the same data as a real month grid, aligned
/// to actual weekdays.
class MonthlyProgressBar extends StatefulWidget {
  /// Date key ("yyyy-MM-dd") → status, straight from the repository.
  final Map<String, String> dailyLog;

  final VoidCallback? onMarkTodayOff;

  const MonthlyProgressBar({
    super.key,
    required this.dailyLog,
    this.onMarkTodayOff,
  });

  @override
  State<MonthlyProgressBar> createState() => _MonthlyProgressBarState();
}

class _MonthlyProgressBarState extends State<MonthlyProgressBar> {
  bool _expanded = false;

  /// The first day the user ever recorded anything. Days before it are
  /// [_DayState.untracked] — the app cannot fairly call them missed.
  DateTime? _trackingStart() {
    DateTime? earliest;
    for (final key in widget.dailyLog.keys) {
      final parsed = DateTime.tryParse(key);
      if (parsed == null) continue;
      if (earliest == null || parsed.isBefore(earliest)) earliest = parsed;
    }
    return earliest;
  }

  _DayState _stateFor(DateTime day, DateTime today, DateTime? start) {
    final status = widget.dailyLog[dateKey(day)];
    if (status == AppConstants.dayStatusDone) return _DayState.done;
    if (status == AppConstants.dayStatusOff) return _DayState.off;
    if (status == AppConstants.dayStatusMissed) return _DayState.missed;

    if (day.isAfter(today)) return _DayState.future;
    if (_isSameDay(day, today)) return _DayState.today;
    if (start == null || day.isBefore(dateOnly(start))) {
      return _DayState.untracked;
    }
    return _DayState.missed;
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
    final start = _trackingStart();

    final days = List<DateTime>.generate(
      daysInMonth,
      (i) => DateTime(today.year, today.month, i + 1),
    );
    final states = [
      for (final day in days) _stateFor(day, today, start),
    ];

    final doneCount = states.where((s) => s == _DayState.done).length;
    final offCount = states.where((s) => s == _DayState.off).length;
    final missedCount = states.where((s) => s == _DayState.missed).length;

    // Compare against the days actually tracked so far, not the whole
    // month — counting days that haven't happened yet against the user
    // makes a perfect week read as a failure.
    final trackedSoFar =
        doneCount + offCount + missedCount + (states.contains(_DayState.today) ? 1 : 0);

    final todayLogged = widget.dailyLog.containsKey(dateKey(today));
    final monthLabel = '${_monthNames[today.month - 1]} ${today.year}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.md,
        AppSpacing.screenHorizontal,
        AppSpacing.xs,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondaryGroupedBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(
                    monthLabel: monthLabel,
                    today: today,
                    daysInMonth: daysInMonth,
                    doneCount: doneCount,
                    trackedSoFar: trackedSoFar,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _MonthStripe(days: days, states: states),
                  const SizedBox(height: AppSpacing.sm),
                  _statsRow(
                    doneCount: doneCount,
                    offCount: offCount,
                    missedCount: missedCount,
                    todayLogged: todayLogged,
                  ),

                  // Month grid — same data, laid out on real weekdays.
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: _expanded
                        ? _MonthGrid(days: days, states: states)
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header({
    required String monthLabel,
    required DateTime today,
    required int daysInMonth,
    required int doneCount,
    required int trackedSoFar,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Monthly Progress', style: AppTypography.headline),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.tertiaryLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '$monthLabel · Day ${today.day} of $daysInMonth',
                style: AppTypography.caption1
                    .copyWith(color: AppColors.secondaryLabel),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryMuted,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: Text(
            // Practised days out of the days tracked so far.
            '$doneCount/${trackedSoFar == 0 ? 1 : trackedSoFar}',
            style: AppTypography.caption1Medium.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statsRow({
    required int doneCount,
    required int offCount,
    required int missedCount,
    required bool todayLogged,
  }) {
    final parts = <String>['$doneCount done'];
    if (offCount > 0) parts.add('$offCount off');
    if (missedCount > 0) parts.add('$missedCount missed');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            parts.join(' · '),
            style: AppTypography.caption1
                .copyWith(color: AppColors.secondaryLabel),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!todayLogged && widget.onMarkTodayOff != null)
          GestureDetector(
            onTap: widget.onMarkTodayOff,
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: Text(
                'Mark today off',
                style: AppTypography.caption1Medium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared visual language for a day
// ─────────────────────────────────────────────────────────────────────────────

/// Height of a day column in the stripe. Decided days — practised or
/// missed — stand at full height so green and red read as one pattern;
/// a rest day sits lower, and a day that hasn't happened is barely there.
double _stripeHeight(_DayState state) {
  switch (state) {
    case _DayState.done:
    case _DayState.missed:
    case _DayState.today:
      return 24;
    case _DayState.off:
      return 13;
    case _DayState.future:
    case _DayState.untracked:
      return 5;
  }
}

/// Fill for a day: green for practised, red for missed. A declared rest
/// day stays sage — it was a deliberate choice, not a lapse, so it is
/// never marked red.
Color _dayFill(_DayState state, double progressAlongMonth) {
  switch (state) {
    case _DayState.done:
      return Color.lerp(
        AppColors.primary,
        AppColors.primaryLight,
        progressAlongMonth,
      )!;
    case _DayState.off:
      return AppColors.primaryContainer;
    case _DayState.missed:
      return AppColors.systemRed;
    case _DayState.today:
      return Colors.transparent;
    case _DayState.future:
    case _DayState.untracked:
      return AppColors.systemGray5;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// The stripe
// ─────────────────────────────────────────────────────────────────────────────

/// One column per day of the month, centred on a common baseline.
class _MonthStripe extends StatelessWidget {
  final List<DateTime> days;
  final List<_DayState> states;

  const _MonthStripe({required this.days, required this.states});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < days.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            Expanded(
              child: _StripeColumn(
                state: states[i],
                progressAlongMonth:
                    days.length <= 1 ? 0.0 : i / (days.length - 1),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StripeColumn extends StatelessWidget {
  final _DayState state;
  final double progressAlongMonth;

  const _StripeColumn({
    required this.state,
    required this.progressAlongMonth,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = state == _DayState.today;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        height: _stripeHeight(state),
        decoration: BoxDecoration(
          color: _dayFill(state, progressAlongMonth),
          borderRadius: BorderRadius.circular(3),
          border:
              isToday ? Border.all(color: AppColors.primary, width: 1.6) : null,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// The month grid
// ─────────────────────────────────────────────────────────────────────────────

/// The same month laid out on real weekdays (Monday first), so the user
/// can read their pattern — which weekdays they keep skipping — rather
/// than only a total.
class _MonthGrid extends StatelessWidget {
  final List<DateTime> days;
  final List<_DayState> states;

  const _MonthGrid({required this.days, required this.states});

  static const _weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    // DateTime.weekday: Monday = 1 … Sunday = 7.
    final leadingBlanks = days.first.weekday - 1;

    final cells = <Widget>[
      for (var i = 0; i < leadingBlanks; i++) const _GridCell.blank(),
      for (var i = 0; i < days.length; i++)
        _GridCell(
          day: days[i],
          state: states[i],
          progressAlongMonth: days.length <= 1 ? 0.0 : i / (days.length - 1),
        ),
    ];
    while (cells.length % 7 != 0) {
      cells.add(const _GridCell.blank());
    }

    final rows = <Widget>[];
    for (var i = 0; i < cells.length; i += 7) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              for (var j = 0; j < 7; j++) ...[
                if (j > 0) const SizedBox(width: 4),
                Expanded(child: cells[i + j]),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        Divider(height: 1, thickness: 0.5, color: AppColors.separator),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            for (var j = 0; j < 7; j++) ...[
              if (j > 0) const SizedBox(width: 4),
              Expanded(
                child: Center(
                  child: Text(
                    _weekdayLabels[j],
                    style: AppTypography.caption2
                        .copyWith(color: AppColors.tertiaryLabel),
                  ),
                ),
              ),
            ],
          ],
        ),
        ...rows,
        const SizedBox(height: AppSpacing.md),
        const _Legend(),
      ],
    );
  }
}

class _GridCell extends StatelessWidget {
  final DateTime? day;
  final _DayState? state;
  final double progressAlongMonth;

  const _GridCell({
    required this.day,
    required this.state,
    required this.progressAlongMonth,
  });

  const _GridCell.blank()
      : day = null,
        state = null,
        progressAlongMonth = 0.0;

  @override
  Widget build(BuildContext context) {
    final d = day;
    final s = state;
    if (d == null || s == null) {
      return const AspectRatio(aspectRatio: 1, child: SizedBox());
    }

    final isToday = s == _DayState.today;
    final isDone = s == _DayState.done;
    final isMissed = s == _DayState.missed;

    // The grid needs more contrast than the stripe: a 5px-tall track
    // colour would read as a filled square here.
    final Color fill;
    switch (s) {
      case _DayState.done:
        fill = Color.lerp(
          AppColors.primary,
          AppColors.primaryLight,
          progressAlongMonth,
        )!;
        break;
      case _DayState.off:
        fill = AppColors.primaryContainer;
        break;
      case _DayState.missed:
        fill = AppColors.systemRed;
        break;
      case _DayState.today:
      case _DayState.future:
      case _DayState.untracked:
        fill = Colors.transparent;
        break;
    }

    final Color textColor;
    if (isDone || isMissed) {
      textColor = Colors.white;
    } else if (s == _DayState.off) {
      textColor = AppColors.primaryDark;
    } else if (isToday) {
      textColor = AppColors.primary;
    } else {
      textColor = AppColors.tertiaryLabel;
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(7),
          border: isToday
              ? Border.all(color: AppColors.primary, width: 1.6)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '${d.day}',
          style: AppTypography.caption2.copyWith(
            color: textColor,
            fontWeight: isDone || isMissed || isToday
                ? FontWeight.w700
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: AppSpacing.md,
      runSpacing: 6,
      children: [
        _LegendChip(label: 'Practised', state: _DayState.done),
        _LegendChip(label: 'Rest day', state: _DayState.off),
        _LegendChip(label: 'Missed', state: _DayState.missed),
        _LegendChip(label: 'Today', state: _DayState.today),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  final String label;
  final _DayState state;

  const _LegendChip({required this.label, required this.state});

  @override
  Widget build(BuildContext context) {
    final isToday = state == _DayState.today;
    final fill = _dayFill(state, 0.5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isToday ? Colors.transparent : fill,
            borderRadius: BorderRadius.circular(3),
            border: isToday
                ? Border.all(color: AppColors.primary, width: 1.4)
                : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style:
              AppTypography.caption2.copyWith(color: AppColors.secondaryLabel),
        ),
      ],
    );
  }
}
