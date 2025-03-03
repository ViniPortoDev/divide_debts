import 'package:divide_debts/app/controller/home_controller.dart';
import 'package:divide_debts/app/models/debt_model.dart';
import 'package:divide_debts/app/models/user_model.dart';
import 'package:divide_debts/app/view/widgets/custom_text_form_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = HomeController();

  // Controllers para adicionar usuários
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userSalaryController = TextEditingController();

  // Controllers para adicionar dívidas
  final TextEditingController _debtNameController = TextEditingController();
  final TextEditingController _debtValueController = TextEditingController();
  DateTime? _selectedDebtDate;

  // Variável para definir se a nova dívida será dividida igualmente
  bool _newDebtEqual = false;

  @override
  void initState() {
    super.initState();
    _controller.loadData().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Divide Contas',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xffc40000),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAddUserCard(),
            const SizedBox(height: 16),
            _buildUserListCard(),
            const SizedBox(height: 16),
            _buildDebtSection(),
          ],
        ),
      ),
    );
  }

  // Card para adicionar um novo usuário
  Widget _buildAddUserCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adicionar Usuário',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            CustomTextFormFieldWidget(
              hintText: 'Nome',
              controller: _userNameController,
            ),
            const SizedBox(height: 12),
            CustomTextFormFieldWidget(
              hintText: 'Salário',
              controller: _userSalaryController,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffc40000),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  _controller.addUser(
                    _userNameController.text,
                    _userSalaryController.text,
                  );
                  _userNameController.clear();
                  _userSalaryController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Adicionar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card para listar os usuários
  Widget _buildUserListCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Usuários',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _controller.users.isEmpty
                ? const Text('Nenhum usuário adicionado.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _controller.users.length,
                    itemBuilder: (context, index) {
                      final user = _controller.users[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xffc40000),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            'Salário: R\$${user.salary.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Color(0xffc40000)),
                              onPressed: () => _editUserDialog(index, user),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _controller.deleteUser(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  // Seção de dívidas: adiciona dívida, lista dívidas e exibe resumo total
  Widget _buildDebtSection() {
    return Column(
      children: [
        _buildAddDebtCard(),
        const SizedBox(height: 16),
        _buildDebtListCard(),
        const SizedBox(height: 16),
        _buildTotalSummaryCard(),
      ],
    );
  }

  // Card para adicionar uma dívida com opção individual de divisão
  Widget _buildAddDebtCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adicionar Dívida',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            CustomTextFormFieldWidget(
              hintText: 'Nome',
              controller: _debtNameController,
            ),
            const SizedBox(height: 12),
            CustomTextFormFieldWidget(
              hintText: 'Valor',
              controller: _debtValueController,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Data: ${DateFormat('dd/MM/yyyy').format(_selectedDebtDate ?? DateTime.now())}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today,
                      color: Color(0xffc40000)),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDebtDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDebtDate = pickedDate;
                      });
                    }
                  },
                ),
              ],
            ),
            // Toggle para definir se a nova dívida será dividida igualmente
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dividir igualmente'),
                Switch(
                  value: _newDebtEqual,
                  onChanged: (value) {
                    setState(() {
                      _newDebtEqual = value;
                    });
                  },
                  activeColor: const Color(0xffc40000),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffc40000),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  _controller.addDebt(
                    _debtNameController.text,
                    _debtValueController.text,
                    date: _selectedDebtDate,
                    isEqualSplit: _newDebtEqual,
                  );
                  _debtNameController.clear();
                  _debtValueController.clear();
                  _selectedDebtDate = null;
                  setState(() {
                    _newDebtEqual = false;
                  });
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Adicionar Dívida',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card para listar as dívidas com opção individual de divisão
  Widget _buildDebtListCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _controller.debts.isEmpty
            ? const Text('Nenhuma dívida adicionada.')
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _controller.debts.length,
                itemBuilder: (context, index) {
                  final debt = _controller.debts[index];
                  return _buildDebtItem(index, debt);
                },
              ),
      ),
    );
  }

  // Widget para exibir cada dívida com toggle individual e divisão dos valores
  Widget _buildDebtItem(int index, Debt debt) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com nome da dívida e data
            Row(
              children: [
                const Icon(Icons.attach_money, color: Color(0xffc40000)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    debt.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(debt.date),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            // Toggle para definir o modo de divisão individual da dívida
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Dividir igualmente'),
                Switch(
                  value: debt.isEqualSplit,
                  onChanged: (value) {
                    setState(() {
                      // Atualiza a dívida com o novo modo de divisão
                      _controller.debts[index] = Debt(
                        name: debt.name,
                        value: debt.value,
                        date: debt.date,
                        isEqualSplit: value,
                      );
                      _controller.saveData();
                    });
                  },
                  activeColor: const Color(0xffc40000),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Total: R\$${debt.value.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Divider(height: 24, thickness: 1),
            // Listagem da divisão da dívida entre os usuários
            Column(
              children: _controller.users.map((user) {
                double userPortion;
                if (debt.isEqualSplit) {
                  userPortion = _controller.users.isNotEmpty
                      ? debt.value / _controller.users.length
                      : 0;
                } else {
                  double totalSalary = _controller.totalSalary;
                  userPortion = totalSalary > 0
                      ? debt.value * (user.salary / totalSalary)
                      : 0;
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(user.name, style: const TextStyle(fontSize: 14)),
                      Text(
                        'R\$${userPortion.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xffc40000)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xffc40000)),
                  onPressed: () => _editDebtDialog(index, debt),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _controller.deleteDebt(index);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Card de resumo total das dívidas
  Widget _buildTotalSummaryCard() {
    double totalDebt = _controller.totalDebt;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumo Total',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Total das dívidas: R\$${totalDebt.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            ..._controller.users.map((user) {
              double userTotal = totalDebt *
                  (_controller.totalSalary > 0
                      ? user.salary / _controller.totalSalary
                      : 0);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(user.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('R\$${userTotal.toStringAsFixed(2)}',
                        style: const TextStyle(color: Color(0xffc40000))),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Diálogo para editar um usuário
  Future<void> _editUserDialog(int index, User user) async {
    final nameController = TextEditingController(text: user.name);
    final salaryController =
        TextEditingController(text: user.salary.toString());
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Usuário'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: salaryController,
                decoration: const InputDecoration(labelText: 'Salário'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffc40000)),
              onPressed: () {
                setState(() {
                  _controller.editUser(
                      index, nameController.text, salaryController.text);
                });
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  // Diálogo para editar uma dívida, incluindo opção individual de divisão
  Future<void> _editDebtDialog(int index, Debt debt) async {
    DateTime selectedDate = debt.date;
    final nameController = TextEditingController(text: debt.name);
    final valueController = TextEditingController(text: debt.value.toString());
    // Variável local para o estado do switch de divisão individual
    bool localEqual = debt.isEqualSplit;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Editar Dívida'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valueController,
                  decoration: const InputDecoration(labelText: 'Valor'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                          'Data: ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today,
                          color: Color(0xffc40000)),
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setStateDialog(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                    ),
                  ],
                ),
                // Toggle para definir o modo de divisão individual da dívida
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Dividir igualmente'),
                    Switch(
                      value: localEqual,
                      onChanged: (value) {
                        setStateDialog(() {
                          localEqual = value;
                        });
                      },
                      activeColor: const Color(0xffc40000),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffc40000)),
                onPressed: () {
                  setState(() {
                    _controller.editDebt(
                        index, nameController.text, valueController.text,
                        date: selectedDate);
                    // Atualiza o modo de divisão da dívida
                    _controller.debts[index] = Debt(
                      name: _controller.debts[index].name,
                      value: _controller.debts[index].value,
                      date: _controller.debts[index].date,
                      isEqualSplit: localEqual,
                    );
                    _controller.saveData();
                  });
                  Navigator.pop(context);
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        });
      },
    );
  }
}
