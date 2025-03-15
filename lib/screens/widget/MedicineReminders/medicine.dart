import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  String id;
  String name;
  double dosage;
  String dosageUnit;
  List<String> doses;
  int quantity;
  String quantityUnit;
  String durationType;
  int durationValue;
  String notes;
  bool notificationsEnabled;
  int quantityLeft;
  bool isRoundTheClock;
  int roundInterval;
  int roundTimes;
  String roundStartTime;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.dosageUnit,
    required this.doses,
    required this.quantity,
    required this.quantityUnit,
    required this.durationType,
    required this.durationValue,
    required this.notes,
    this.notificationsEnabled = false,
    this.quantityLeft = 0,
    this.isRoundTheClock = false,
    this.roundInterval = 4,
    this.roundTimes = 3,
    this.roundStartTime = '8:00 AM',
  });

  factory Medicine.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Medicine(
      id: doc.id,
      name: data['name'] ?? '',
      dosage: (data['dosage'] ?? 0).toDouble(),
      dosageUnit: data['dosageUnit'] ?? 'mg',
      doses: List<String>.from(data['doses'] ?? []),
      quantity: data['quantity'] ?? 0,
      quantityUnit: data['quantityUnit'] ?? 'Tablets',
      durationType: data['durationType'] ?? 'Everyday',
      durationValue: data['durationValue'] ?? 7,
      notes: data['notes'] ?? '',
      notificationsEnabled: data['notificationsEnabled'] ?? false,
      quantityLeft: data['quantityLeft'] ?? 0,
      isRoundTheClock: data['isRoundTheClock'] ?? false,
      roundInterval: data['roundInterval'] ?? 4,
      roundTimes: data['roundTimes'] ?? 3,
      roundStartTime: data['roundStartTime'] ?? '8:00 AM',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'dosageUnit': dosageUnit,
      'doses': doses,
      'quantity': quantity,
      'quantityUnit': quantityUnit,
      'durationType': durationType,
      'durationValue': durationValue,
      'notes': notes,
      'notificationsEnabled': notificationsEnabled,
      'quantityLeft': quantityLeft,
      'isRoundTheClock': isRoundTheClock,
      'roundInterval': roundInterval,
      'roundTimes': roundTimes,
      'roundStartTime': roundStartTime,
    };
  }
}
