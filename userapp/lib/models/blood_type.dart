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
      id: (json['id'] as num).toInt(),
      label: json['label'] as String? ?? '',
      aboGroup: json['aboGroup'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'aboGroup': aboGroup,
    };
  }

  @override
  String toString() => aboGroup;
}