import 'package:flutter/material.dart';

class CustomTextFormFieldWidget extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String? hintText;
  final TextInputType? keyboardType;
  const CustomTextFormFieldWidget({
    super.key,
    this.hintText,
    this.controller,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      keyboardType: keyboardType,
    );
  }
}
