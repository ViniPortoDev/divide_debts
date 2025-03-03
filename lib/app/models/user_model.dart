class User {
  final String name;
  final double salary;
  
  User({required this.name, required this.salary});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'salary': salary,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'],
      salary: (map['salary'] as num).toDouble(),
    );
  }
}
