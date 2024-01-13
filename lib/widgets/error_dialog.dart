import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomErrorDialog extends StatelessWidget {
  var message;

  CustomErrorDialog({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      key: key,
      content: Text(message!),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                )),
            child: const Center(
                child: Text(
              'OK',
              style: TextStyle(color: Colors.white),
            )),
          ),
        ),
      ],
    );
  }
}

class SnackBarHelper {
  static void showSnackBar(
    GlobalKey<ScaffoldMessengerState> scaffoldKey,
    String message,
  ) {
    scaffoldKey.currentState!.hideCurrentSnackBar();
    scaffoldKey.currentState!.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.grey.shade100.withOpacity(0.5),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
    );
  }
}
