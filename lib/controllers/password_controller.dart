import 'package:get/get.dart';

class PasswordController extends GetxController {
  RxBool obscureText = true.obs;
  void changeObscureText() {
    obscureText.value = !obscureText.value;
  }
}
