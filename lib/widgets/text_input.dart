import 'package:ebook_tuh/constants/app_font_size.dart';
import 'package:flutter/material.dart';

import '../constants/app_color.dart';

class MyTextField extends StatefulWidget {
  String labelText;
  TextEditingController controller;
  bool obscureText;
  bool isNumber;
  String prefixIcon;
  String? Function(String?)? validator;

  MyTextField(
      {super.key, required this.labelText,
        required this.controller,
        required this.obscureText,
        required this.isNumber,
        required this.prefixIcon,
        this.validator,
      });

  @override
  State<StatefulWidget> createState() {
    return MyTextFieldState();
  }
}

class MyTextFieldState extends State<MyTextField> {
  bool _show = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText && !_show,
      style: const TextStyle(
        color: Colors.black,
        fontSize: AppFontSize.small,
        fontWeight: FontWeight.normal,
      ),
      keyboardType: widget.isNumber ? TextInputType.number : TextInputType.text,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: Colors.black.withOpacity(0.7),
          fontSize: AppFontSize.small
        ),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF8360c3), width: 2.0), // Viền dày hơn khi focus
          borderRadius: BorderRadius.circular(12.0),
        ),
        errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red)),
        focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red)),
        fillColor: Colors.white,
        filled: true,
        suffixIcon: widget.obscureText
            ? IconButton(
          icon: Icon(_show ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _show = !_show;
            });
          },
        )
            : null,
        prefixIcon: Padding(
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: Image.asset(
              widget.prefixIcon,
              height: 30,
              width: 30,
              fit: BoxFit.contain,
            )),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }
}