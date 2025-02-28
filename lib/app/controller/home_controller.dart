import 'package:divide_debts/app/models/debt_model.dart';
import 'package:divide_debts/app/models/user_model.dart';

class HomeController {
  List<User> users = [];
  List<Debt> debts = [];
  bool isEqualDivision = false; // Modo divisão igualitária

  // Adiciona um usuário (sem validação)
  void addUser(String name, String salaryStr) {
    // Se for divisão igual, o salário é ignorado (poderia ser 1 como valor padrão)
    double salary = isEqualDivision ? 1 : (double.tryParse(salaryStr) ?? 0);
    users.add(User(name: name, salary: salary));
  }

  // Edita um usuário existente
  void editUser(int index, String name, String salaryStr) {
    double salary = isEqualDivision ? 1 : (double.tryParse(salaryStr) ?? 0);
    users[index] = User(name: name, salary: salary);
  }

  // Exclui um usuário
  void deleteUser(int index) {
    users.removeAt(index);
  }

  // Soma total de todos os salários
  double get totalSalary => users.fold(0, (sum, user) => sum + user.salary);

  // Calcula a porcentagem que um usuário deve pagar
  double userPercentage(User user) {
    if (isEqualDivision && users.isNotEmpty) {
      return 1 / users.length;
    }
    return totalSalary > 0 ? user.salary / totalSalary : 0;
  }

  // Adiciona uma dívida no início da lista (para que a mais nova apareça primeiro)
  void addDebt(String name, String valueStr, {DateTime? date}) {
    double value = double.tryParse(valueStr) ?? 0;
    DateTime debtDate = date ?? DateTime.now();
    debts.insert(0, Debt(name: name, value: value, date: debtDate));
  }

  // Edita uma dívida existente
  void editDebt(int index, String name, String valueStr, {DateTime? date}) {
    double value = double.tryParse(valueStr) ?? 0;
    DateTime debtDate = date ?? DateTime.now();
    debts[index] = Debt(name: name, value: value, date: debtDate);
  }

  // Exclui uma dívida
  void deleteDebt(int index) {
    debts.removeAt(index);
  }

  // Soma total de todas as dívidas
  double get totalDebt => debts.fold(0, (sum, debt) => sum + debt.value);
}
