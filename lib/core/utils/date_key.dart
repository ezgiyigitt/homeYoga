/// Small shared helper for turning [DateTime]s into the "yyyy-MM-dd"
/// keys used by the daily check-in log (LocalStorage.dailyLog /
/// IProgressRepository.getDailyLog & setDayStatus), so Home's monthly
/// progress bar and the İlerleme "garden" popup can't drift out of
/// sync with how the repository actually stores dates.
String dateKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// Earliest date actually present in a daily check-in log, or null if
/// it's empty (the user has never logged anything yet). Shared by the
/// Home monthly progress bar and the İlerleme garden popup so neither
/// one judges a day "missed" before the user ever started tracking —
/// see MonthlyProgressBar's doc comment for why that matters.
DateTime? earliestLoggedDate(Map<String, String> dailyLog) {
  DateTime? earliest;
  for (final key in dailyLog.keys) {
    final parts = key.split('-');
    if (parts.length != 3) continue;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) continue;
    final date = DateTime(y, m, d);
    if (earliest == null || date.isBefore(earliest)) earliest = date;
  }
  return earliest;
}
