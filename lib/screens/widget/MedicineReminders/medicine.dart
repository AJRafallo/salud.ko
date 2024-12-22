class Medicine {
  final String id;
  final String name;
  final double dosage;
  final String dosageUnit;
  final List<String> doses;
  final int quantity;
  final String quantityUnit;
  final String durationType;
  final int durationValue;
  final String notes;

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
  });

  Medicine copyWith({
    String? id,
    String? name,
    double? dosage,
    String? dosageUnit,
    List<String>? doses,
    int? quantity,
    String? quantityUnit,
    String? durationType,
    int? durationValue,
    String? notes,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      doses: doses ?? this.doses,
      quantity: quantity ?? this.quantity,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      durationType: durationType ?? this.durationType,
      durationValue: durationValue ?? this.durationValue,
      notes: notes ?? this.notes,
    );
  }
}
