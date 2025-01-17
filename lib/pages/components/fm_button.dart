import 'package:flutter/material.dart';

// ignore: must_be_immutable
class FmButton extends StatelessWidget {
  final String text;
  VoidCallback onPressed;

  FmButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
