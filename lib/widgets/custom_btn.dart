import 'package:flutter/material.dart';

class CustomBTN extends StatelessWidget {
  final String? label;
  final Function()? onpressed;

  const CustomBTN({
    super.key,
    required this.label,
    required this.onpressed,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return InkWell(
      onTap: onpressed,
      child: Container(
        alignment: Alignment.center,
        height: size.height * 0.057,
        width: size.width * 0.7,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label!,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
