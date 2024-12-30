import 'package:flutter/material.dart';

String formatTimeOfDay(TimeOfDay t) {
  final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  final minuteStr = t.minute.toString().padLeft(2, '0');
  final amPm = t.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minuteStr $amPm';
}

// Returns ordinal representation of an integer, e.g. 1 -> "1st", 2 -> "2nd"
String ordinal(int number) {
  if (number % 100 >= 11 && number % 100 <= 13) {
    return '${number}th';
  }
  switch (number % 10) {
    case 1:
      return '${number}st';
    case 2:
      return '${number}nd';
    case 3:
      return '${number}rd';
    default:
      return '${number}th';
  }
}
