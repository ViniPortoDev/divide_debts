import 'dart:convert';
import 'package:divide_debts/app/models/debt_model.dart';
import 'package:divide_debts/app/models/user_model.dart';
import 'package:divide_debts/app/service/shared_preference_service.dart';

class HomeController {
  List<User> users = [];
  List<Debt> debts = [];
  bool isEqualDivision =
      false; // Modo global para criação de usuário (não afeta o modo individual de dívida)

  // Salva os dados usando o SharedPreferencesService
  Future<void> saveData() async {
    List<String> usersJson =
        users.map((user) => jsonEncode(user.toMap())).toList();
    List<String> debtsJson =
        debts.map((debt) => jsonEncode(debt.toMap())).toList();
    await SharedPreferencesService.setString('users', jsonEncode(usersJson));
    await SharedPreferencesService.setString('debts', jsonEncode(debtsJson));
    await SharedPreferencesService.setBool('isEqualDivision', isEqualDivision);
  }

  // Carrega os dados salvos
  Future<void> loadData() async {
    String? usersStr = await SharedPreferencesService.getString('users');
    String? debtsStr = await SharedPreferencesService.getString('debts');
    bool? savedEqualDivision =
        await SharedPreferencesService.getBool('isEqualDivision');

    if (savedEqualDivision != null) {
      isEqualDivision = savedEqualDivision;
    }

    if (usersStr != null) {
      List<dynamic> decodedUsers = jsonDecode(usersStr);
      users = decodedUsers.map((str) => User.fromMap(jsonDecode(str))).toList();
    }
    if (debtsStr != null) {
      List<dynamic> decodedDebts = jsonDecode(debtsStr);
      debts = decodedDebts.map((str) => Debt.fromMap(jsonDecode(str))).toList();
    }
  }

  // Métodos para usuários
  void addUser(String name, String salaryStr) {
    double salary = isEqualDivision ? 1 : (double.tryParse(salaryStr) ?? 0);
    users.add(User(name: name, salary: salary));
    saveData();
  }

  void editUser(int index, String name, String salaryStr) {
    double salary = isEqualDivision ? 1 : (double.tryParse(salaryStr) ?? 0);
    users[index] = User(name: name, salary: salary);
    saveData();
  }

  void deleteUser(int index) {
    users.removeAt(index);
    saveData();
  }

  double get totalSalary => users.fold(0, (sum, user) => sum + user.salary);

  double userPercentage(User user) {
    if (isEqualDivision && users.isNotEmpty) {
      return 1 / users.length;
    }
    return totalSalary > 0 ? user.salary / totalSalary : 0;
  }

  // Métodos para dívidas com suporte à divisão individual
  void addDebt(String name, String valueStr,
      {DateTime? date, bool isEqualSplit = false}) {
    double value = double.tryParse(valueStr) ?? 0;
    DateTime debtDate = date ?? DateTime.now();
    debts.insert(
        0,
        Debt(
            name: name,
            value: value,
            date: debtDate,
            isEqualSplit: isEqualSplit));
    saveData();
  }

  void editDebt(int index, String name, String valueStr,
      {DateTime? date, bool? isEqualSplit}) {
    double value = double.tryParse(valueStr) ?? 0;
    DateTime debtDate = date ?? DateTime.now();
    bool currentEqual = isEqualSplit ?? debts[index].isEqualSplit;
    debts[index] = Debt(
        name: name, value: value, date: debtDate, isEqualSplit: currentEqual);
    saveData();
  }

  void deleteDebt(int index) {
    debts.removeAt(index);
    saveData();
  }

  double get totalDebt => debts.fold(0, (sum, debt) => sum + debt.value);
}
