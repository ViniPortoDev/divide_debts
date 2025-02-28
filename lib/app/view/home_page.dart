import 'package:divide_debts/app/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:divide_debts/app/view/widgets/custom_text_form_field_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = HomeController();
  final TextEditingController _salary1Controller = TextEditingController();
  final TextEditingController _salary2Controller = TextEditingController();
  final TextEditingController _debtNameController = TextEditingController();
  final TextEditingController _debtValueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Divide Contas'),
        centerTitle: true,
        backgroundColor: const Color(0xffC40000),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSalaryCard(),
            const SizedBox(height: 16),
            _buildPercentageCard(),
            const SizedBox(height: 16),
            _buildAddDebtCard(),
            const SizedBox(height: 16),
            _buildDebtListCard(),
          ],
        ),
      ),
    );
  }

  // Card de entrada dos salários
  Widget _buildSalaryCard() {
    return _buildCard(
      title: 'Defina os Salários',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextFormFieldWidget(
                  hintText: 'Salário 1',
                  controller: _salary1Controller,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextFormFieldWidget(
                  hintText: 'Salário 2',
                  controller: _salary2Controller,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                _controller.setSalaries(
                  _salary1Controller.text,
                  _salary2Controller.text,
                );
                setState(() {});
              },
              style: _buttonStyle(),
              child: const Text('Calcular'),
            ),
          ),
        ],
      ),
    );
  }

  // Card para exibir os percentuais calculados
  Widget _buildPercentageCard() {
    return _buildCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPercentageInfo('Usuário 1', _controller.user1Percentage),
          _buildPercentageInfo('Usuário 2', _controller.user2Percentage),
        ],
      ),
    );
  }

  // Método que exibe a porcentagem que cada usuário deve pagar
  Widget _buildPercentageInfo(String title, double percentage) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '${(percentage * 100).toStringAsFixed(2)}%',
          style: const TextStyle(
              fontSize: 18,
              color: Color(0xffC40000),
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Card para adicionar dívidas
  Widget _buildAddDebtCard() {
    return _buildCard(
      title: 'Adicionar Dívida',
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: CustomTextFormFieldWidget(
              hintText: 'Nome',
              controller: _debtNameController,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: CustomTextFormFieldWidget(
              hintText: 'Valor',
              controller: _debtValueController,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              _controller.addDebt(
                _debtNameController.text,
                _debtValueController.text,
              );
              _debtNameController.clear();
              _debtValueController.clear();
              setState(() {});
            },
            icon: const Icon(Icons.add_circle_outline,
                size: 32, color: Color(0xffC40000)),
          ),
        ],
      ),
    );
  }

  // Card de listagem de dívidas e resumo total
  Widget _buildDebtListCard() {
    return _buildCard(
      title: 'Dívidas',
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _controller.debts.length + 1,
            itemBuilder: (context, index) {
              if (index < _controller.debts.length) {
                final debt = _controller.debts.reversed
                    .toList()[index]; // Invertendo a ordem
                double amountUser1 = debt.value * _controller.user1Percentage;
                double amountUser2 = debt.value * _controller.user2Percentage;
                return _buildDebtItem(
                    index + 1, debt.name, debt.value, amountUser1, amountUser2);
              } else {
                return _buildTotalSummary();
              }
            },
          ),
        ],
      ),
    );
  }

  // Widget para exibir cada dívida
  Widget _buildDebtItem(
      int index, String name, double value, double user1Pay, double user2Pay) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: _boxDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xffC40000),
            child: Text(
              index.toString(),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: _boldTextStyle()),
                Text('Total: R\$${value.toStringAsFixed(2)}',
                    style: _regularTextStyle()),
                Text(
                  'Usuário 1: R\$${user1Pay.toStringAsFixed(2)} | Usuário 2: R\$${user2Pay.toStringAsFixed(2)}',
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xffC40000)),
                ),
              ],
            ),
          ),
          const Icon(Icons.money_off, color: Colors.redAccent),
        ],
      ),
    );
  }

  // Resumo total das dívidas
  Widget _buildTotalSummary() {
    double totalDebt = _controller.totalDebt;
    double totalUser1 = totalDebt * _controller.user1Percentage;
    double totalUser2 = totalDebt * _controller.user2Percentage;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: _boxDecoration(color: const Color(0xffC40000).withOpacity(0.1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumo Total',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Total das dívidas: R\$${totalDebt.toStringAsFixed(2)}',
              style: _regularTextStyle()),
          const SizedBox(height: 4),
          Text(
            'Usuário 1 paga: R\$${totalUser1.toStringAsFixed(2)} | Usuário 2 paga: R\$${totalUser2.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14, color: Color(0xffC40000)),
          ),
        ],
      ),
    );
  }

  // Helpers de UI
  Widget _buildCard({String? title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(title, style: _boldTextStyle()),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffC40000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  BoxDecoration _boxDecoration({Color color = Colors.white}) => BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      );

  TextStyle _boldTextStyle() =>
      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  TextStyle _regularTextStyle() => const TextStyle(fontSize: 14);
}
