import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final TextInputType inputType;
  final TextInputAction? inputAction;
  final String? Function(String?)? validator;
  final bool readOnly;
  final bool obscureText;
  final VoidCallback? onTap;
  final void Function(String)? onFieldSubmitted;
  final int maxLines;
  final Widget? suffixIcon;

  const TextFieldWidget({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.inputType = TextInputType.text,
    this.inputAction,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.obscureText = false,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        keyboardType: inputType,
        textInputAction: inputAction,
        validator: validator,
        onTap: onTap,
        maxLines: obscureText ? 1 : maxLines,
        onFieldSubmitted: onFieldSubmitted,
        style: TextStyle(fontSize: 11.sp),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 10.sp, color: Colors.grey),
          labelStyle: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
          filled: true,
          fillColor: Colors.grey[100],
          suffixIcon: suffixIcon,
          contentPadding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
