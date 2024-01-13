import 'package:flutter/material.dart';
import 'package:spot_finder/controllers/password_controller.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hint;
  final String? label;
  final IconData? icon;
  final TextInputType? keyborad;
  final Color? iconcolor;
  final TextEditingController? controller;
  final Function? openMap;
  final int? maxLines;
  final bool? obscureText;
  final bool? readOnly;
  final PasswordController? passwordController;
  final Function? onTap;

  const CustomTextFormField({
    super.key,
    required this.hint,
    this.label,
    this.icon,
    this.keyborad,
    this.iconcolor,
    this.controller,
    this.openMap,
    this.maxLines,
    this.readOnly,
    this.obscureText,
    this.passwordController,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText ?? false,
      onTap: onTap != null ? () => onTap!() : null,
      focusNode: FocusNode(),
      readOnly: readOnly ?? false,
      maxLines: maxLines ?? 1,
      textAlignVertical: TextAlignVertical.center,
      textDirection: TextDirection.ltr,
      controller: controller,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 0.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 1)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 1)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 0.5,
            )),
        suffixIcon: GestureDetector(
            onTap: () {
              if (openMap != null) {
                openMap!();
              }
              if (passwordController != null) {
                passwordController!.changeObscureText();
              }
            },
            child: Icon(icon)),
        suffixIconColor: iconcolor,
      ),
      keyboardType: keyborad,
    );
  }
}
