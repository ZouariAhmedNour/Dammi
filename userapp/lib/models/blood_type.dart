class BloodType {
  final int id;
  final String label;
  final String aboGroup;

  const BloodType({
    required this.id,
    required this.label,
    required this.aboGroup,
  });

  factory BloodType.fromJson(Map<String, dynamic> json) {
    return BloodType(
      id: json['id'] as int,
      label: (json['label'] ?? '').toString(),
      aboGroup: (json['aboGroup'] ?? '').toString(),
    );
  }

  @override
  String toString() => aboGroup;
}