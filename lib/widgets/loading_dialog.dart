import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spot_finder/widgets/progress_bar.dart';


class LoadingDialog extends StatelessWidget {

  final String? message;
  var key;

  LoadingDialog({
    this.message,
    this.key
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      key: key,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           circularProgressBar(),
          const SizedBox(height: 10,),
          Text('${message!} Please Wait...'),
        ],
      ),
    );
  }
}
