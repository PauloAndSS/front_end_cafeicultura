import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Alignment alignment;
  final Color? textColor;
  final bool isUnderlined;
  final bool isBold;
  final double fontSize;

  const CustomTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.alignment = Alignment.centerRight,
    this.textColor,
    this.isUnderlined = false,
    this.isBold = true,        
    this.fontSize = 14.0,      
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: TextButton(
        style: TextButton.styleFrom(
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: textColor ?? const Color(0xFF0091FF),
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            fontSize: fontSize,
            decoration: isUnderlined ? TextDecoration.underline : TextDecoration.none,
            decorationColor: textColor ?? const Color(0xFF0091FF), 
          ),
        ),
      ),
    );
  }
}