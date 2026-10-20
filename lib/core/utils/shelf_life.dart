/// Turns free text like "12 months", "2 weeks" or "10 days" into days.
/// Returns null when it can't be understood.
int? parseShelfLifeDays(String text) {
  final m = RegExp(r'(\d+(?:\.\d+)?)\s*(day|week|month|year)s?', caseSensitive: false)
      .firstMatch(text.trim());
  if (m == null) return null;
  final n = double.parse(m.group(1)!);
  switch (m.group(2)!.toLowerCase()) {
    case 'day':
      return n.round();
    case 'week':
      return (n * 7).round();
    case 'month':
      return (n * 30).round();
    case 'year':
      return (n * 365).round();
  }
  return null;
}
