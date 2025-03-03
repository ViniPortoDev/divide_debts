class Debt {
  final String name;
  final double value;
  final DateTime date;
  final bool isEqualSplit; // Indica se a dívida será dividida igualmente entre os usuários

  Debt({
    required this.name,
    required this.value,
    required this.date,
    this.isEqualSplit = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
      'date': date.toIso8601String(),
      'isEqualSplit': isEqualSplit,
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      name: map['name'],
      value: (map['value'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      isEqualSplit: map['isEqualSplit'] ?? false,
    );
  }
}
