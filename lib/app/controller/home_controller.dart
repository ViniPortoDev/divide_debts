

// Controller que gerencia os salários e as dívidas
import 'package:divide_debts/app/models/debt_model.dart';

class HomeController {
  double salary1 = 0;
  double salary2 = 0;
  List<Debt> debts = [];

  // Configura os salários (sem validação)
  void setSalaries(String s1, String s2) {
    salary1 = double.tryParse(s1) ?? 0;
    salary2 = double.tryParse(s2) ?? 0;
  }

  double get totalSalary => salary1 + salary2;

  // Percentual que o usuário 1 deve pagar
  double get user1Percentage => totalSalary > 0 ? salary1 / totalSalary : 0;

  // Percentual que o usuário 2 deve pagar
  double get user2Percentage => totalSalary > 0 ? salary2 / totalSalary : 0;

  // Adiciona uma dívida à lista (sem validação)
  void addDebt(String name, String valueStr) {
    double value = double.tryParse(valueStr) ?? 0;
    debts.add(Debt(name: name, value: value));
  }

  // Soma total de todas as dívidas
  double get totalDebt => debts.fold(0, (sum, debt) => sum + debt.value);
}
