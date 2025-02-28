import 'package:divide_debts/app/controller/home_controller.dart';
import 'package:divide_debts/app/models/debt_model.dart';
import 'package:divide_debts/app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:divide_debts/app/view/widgets/custom_text_form_field_widget.dart';
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
            _buildDivisionModeSwitch(),
            const SizedBox(height: 16),
            _buildUserListCard(),
            const SizedBox(height: 16),
            _buildDebtSection(),
          ],
        ),
      ),
    );
  }

  // Widget para alternar entre divisão proporcional e igualitária
  Widget _buildDivisionModeSwitch() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SwitchListTile(
          title: const Text('Dividir igualmente entre todos'),
          value: _controller.isEqualDivision,
          onChanged: (value) {
            setState(() {
              _controller.isEqualDivision = value;
            });
          },
        ),
      ),
    );
  }

  // Card para adicionar um novo usuário com layout vertical
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
            if (!_controller.isEqualDivision) ...[
              const SizedBox(height: 12),
              CustomTextFormFieldWidget(
                hintText: 'Salário',
                controller: _userSalaryController,
              ),
            ],
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
                    _controller.isEqualDivision
                        ? "1"
                        : _userSalaryController.text,
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

  // Card para listar os usuários com ícones no lugar do número
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
                      double percentage = _controller.userPercentage(user);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xffc40000),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: _controller.isEqualDivision
                            ? const Text('Divisão igual')
                            : Text(
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
                            Text(
                              '${(percentage * 100).toStringAsFixed(2)}%',
                              style: const TextStyle(
                                  color: Color(0xffc40000),
                                  fontWeight: FontWeight.bold),
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

  // Card para adicionar uma dívida com layout vertical
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
                  );
                  _debtNameController.clear();
                  _debtValueController.clear();
                  _selectedDebtDate = null;
                  setState(() {});
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

  // Card para listar as dívidas com layout aprimorado
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

  // Widget para exibir cada dívida com layout reorganizado e espaçamentos
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
            const SizedBox(height: 12),
            Text(
              'Total: R\$${debt.value.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Divider(height: 24, thickness: 1),
            Column(
              children: _controller.users.map((user) {
                double userPortion =
                    debt.value * _controller.userPercentage(user);
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

  // Card de resumo total das dívidas com layout minimalista
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
              double userTotal = totalDebt * _controller.userPercentage(user);
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
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Diálogo para editar um usuário com espaçamentos adequados
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
              if (!_controller.isEqualDivision)
                TextField(
                  controller: salaryController,
                  decoration: const InputDecoration(labelText: 'Salário'),
                  keyboardType: TextInputType.number,
                )
              else
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text('Divisão igual ativa. Salário não é necessário.'),
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
                      index,
                      nameController.text,
                      _controller.isEqualDivision
                          ? "1"
                          : salaryController.text);
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

  // Diálogo para editar uma dívida com layout aprimorado
  Future<void> _editDebtDialog(int index, Debt debt) async {
    DateTime selectedDate = debt.date;
    final nameController = TextEditingController(text: debt.name);
    final valueController = TextEditingController(text: debt.value.toString());
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
                            'Data: ${DateFormat('dd/MM/yyyy').format(selectedDate)}')),
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
