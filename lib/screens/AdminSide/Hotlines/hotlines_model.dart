class Hotline {
  String id;
  String name;
  String primaryContact;
  String secondaryContact;
  String description;

  Hotline({
    required this.id,
    required this.name,
    required this.primaryContact,
    required this.secondaryContact,
    this.description = '',
  });

  factory Hotline.fromMap(Map<String, dynamic> data, String documentId) {
    return Hotline(
      id: documentId,
      name: data['name'] ?? '',
      primaryContact: data['primaryContact'] ?? '',
      secondaryContact: data['secondaryContact'] ?? '',
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'primaryContact': primaryContact,
      'secondaryContact': secondaryContact,
      'description': description,
    };
  }
}
