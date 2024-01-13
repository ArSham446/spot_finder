import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spot_finder/controllers/password_controller.dart';
import 'package:spot_finder/services/notification_services.dart';
import 'package:spot_finder/ui/auth/forgot_password.dart';
import 'package:spot_finder/ui/auth/signup_page.dart';
import 'package:spot_finder/ui/bottomNavBar/bottom_nav_bar.dart';

import '../../controllers/controllers.dart';
import '../../global/global.dart';
import '../../widgets/custom_btn.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/loading_dialog.dart';

class CustomerLogin extends StatefulWidget {
  const CustomerLogin({super.key});

  @override
  State<CustomerLogin> createState() => _CustomerLoginState();
}

class _CustomerLoginState extends State<CustomerLogin> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var obscureText = false;

  formValidation() {
    if (userAuthEmailController.text.isNotEmpty &&
        userAuthPasswordController.text.isNotEmpty) {
      //login
      loginNow();
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return CustomErrorDialog(
              message: "Invalid password OR Email",
            );
          });
    }
  }

  loginNow() async {
    showDialog(
        context: context,
        builder: (c) {
          return LoadingDialog(
            message: "Checking Credentials",
          );
        });

    User? currentUser;
    try {
      await firebaseAuth
          .signInWithEmailAndPassword(
        email: userAuthEmailController.text.trim(),
        password: userAuthPasswordController.text.trim(),
      )
          .then((auth) {
        currentUser = auth.user!;
      }).catchError((error) {
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (c) {
              return CustomErrorDialog(
                message: error.message.toString(),
              );
            });
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      showDialog(
          context: context,
          builder: (c) {
            return CustomErrorDialog(
              message: e.toString(),
            );
          });
    }
    if (currentUser != null) {
      readDataAndSetDataLocally(currentUser!);
    }
  }

  Future readDataAndSetDataLocally(User currentUser) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser.uid)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        await _prefs.then((prefs) {
          prefs.setString("uid", currentUser.uid);
        }).then((value) async {
          String token = await NotificationsServices().getToken();
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(currentUser.uid)
              .update({
            "token": token,
          }).whenComplete(() {
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (c) => const CustomerBottomNavBar()),
                (route) => false);
          });
        });
      } else {
        firebaseAuth.signOut();
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const CustomerLogin()));

        showDialog(
            context: context,
            builder: (c) {
              return CustomErrorDialog(
                message: "No Record Found",
              );
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    PasswordController passwordController = Get.put(PasswordController());
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Login',
          style: TextStyle(
              color: Colors.black, fontSize: 26, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/spotFinderBanner.png',
                height: size.height * 0.07,
              ),
              SizedBox(
                height: size.height * 0.07,
              ),
              const Text(
                'Enter the correct details to enter you account',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(
                height: size.height * 0.06,
              ),
              Form(
                  child: Column(
                children: [
                  CustomTextFormField(
                    label: 'Email',
                    hint: 'Enter Email',
                    keyborad: TextInputType.emailAddress,
                    controller: userAuthEmailController,
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Obx(() => CustomTextFormField(
                        obscureText: passwordController.obscureText.value,
                        label: 'Password',
                        hint: 'Enter Password',
                        keyborad: TextInputType.visiblePassword,
                        icon: passwordController.obscureText.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        iconcolor: Colors.black,
                        controller: userAuthPasswordController,
                        passwordController: Get.find<PasswordController>(),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ForgotScreen()));
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  CustomBTN(
                      label: 'Login',
                      onpressed: () {
                        formValidation();
                      }),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  SizedBox(
                    height: size.height * 0.04,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have account?"),
                      TextButton(
                          onPressed: () {
                            Get.delete<PasswordController>();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CustomerSignup()));
                          },
                          child: const Text(
                            'Register',
                            style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                                fontSize: 20),
                          ))
                    ],
                  ),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
