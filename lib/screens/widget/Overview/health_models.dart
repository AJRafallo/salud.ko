import 'package:cloud_firestore/cloud_firestore.dart';

class SleepEntry {
  String id;
  double hours;
  DateTime date;

  SleepEntry({required this.id, required this.hours, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hours': hours,
      'date': Timestamp.fromDate(date),
    };
  }

  factory SleepEntry.fromMap(Map<String, dynamic> map) {
    return SleepEntry(
      id: map['id'] as String,
      hours: (map['hours'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}

class BloodPressureEntry {
  String id;
  double systolic;
  double diastolic;
  DateTime date;

  BloodPressureEntry({
    required this.id,
    required this.systolic,
    required this.diastolic,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'systolic': systolic,
      'diastolic': diastolic,
      'date': Timestamp.fromDate(date),
    };
  }

  factory BloodPressureEntry.fromMap(Map<String, dynamic> map) {
    return BloodPressureEntry(
      id: map['id'] as String,
      systolic: (map['systolic'] as num).toDouble(),
      diastolic: (map['diastolic'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}

class BloodGlucoseEntry {
  String id;
  double value;
  DateTime date;

  BloodGlucoseEntry({
    required this.id,
    required this.value,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
      'date': Timestamp.fromDate(date),
    };
  }

  factory BloodGlucoseEntry.fromMap(Map<String, dynamic> map) {
    return BloodGlucoseEntry(
      id: map['id'] as String,
      value: (map['value'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}
