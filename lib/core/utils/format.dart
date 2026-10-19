const _weekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _weekdayLong = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatTime(DateTime d, {bool alwaysMinutes = false}) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final suffix = d.hour >= 12 ? 'PM' : 'AM';
  final minutes = d.minute.toString().padLeft(2, '0');
  return (alwaysMinutes || d.minute != 0) ? '$h:$minutes $suffix' : '$h $suffix';
}

/// "Closes Thu 8 PM"
String formatClosesShort(DateTime d) =>
    'Closes ${_weekdayShort[d.weekday - 1]} ${formatTime(d)}';

/// "Thursday, 8:00 PM"
String formatDeadlineLong(DateTime d) =>
    '${_weekdayLong[d.weekday - 1]}, ${formatTime(d, alwaysMinutes: true)}';

/// "Oct 3"
String formatShortDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';

/// "৳12,400" (or "৳12400" with commas: false)
String formatTaka(double value, {bool commas = true}) {
  final n = value.round();
  final digits = n.abs().toString();
  var out = digits;
  if (commas) {
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    out = buf.toString();
  }
  return '৳${n < 0 ? '-' : ''}$out';
}
