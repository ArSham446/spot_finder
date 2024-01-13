import 'package:flutter/material.dart';

class CustomListile extends StatelessWidget {

  IconData? tileIcon;
  String? tileTitle;
  var tileOnTap;

  CustomListile({
    required this.tileIcon,
    required this.tileTitle,
    this.tileOnTap,
});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: InkWell(
        onTap: tileOnTap,
        child: ListTile(
          leading: Icon(tileIcon, color: Colors.black,),
          title: Text(tileTitle!),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20,),
        ),
      ),
    );
  }
}
