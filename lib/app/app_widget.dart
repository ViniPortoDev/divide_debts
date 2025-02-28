import 'package:divide_debts/app/view/home_page.dart';
import 'package:flutter/material.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Divide Debts',
      home: HomePage(),
    );
  }
}
