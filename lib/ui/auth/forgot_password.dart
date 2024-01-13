import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spot_finder/widgets/custom_btn.dart';

import '../../controllers/controllers.dart';
import '../../widgets/custom_text_form_field.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {


  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Password reset email sent successfully.
      // Show a success message or navigate to a confirmation screen.
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Password reset email sent.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog.
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // An error occurred while attempting to send the password reset email.
      // Handle the error appropriately, e.g., show an error message.
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to send password reset email: $e'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog.
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      print('Error sending password reset email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Forgot Password',
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.w600),
        ),
          leading: IconButton(onPressed: (){
            Navigator.pop(context);
          }, icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black,),)

      ),
      body:  SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [

              SizedBox(height: size.height*0.02,),
              const Text('Enter a valid email to your account for resseting your password', style: TextStyle(color: Colors.grey),textAlign: TextAlign.center,),
              SizedBox(height: size.height*0.2,),
              CustomTextFormField(
                label: 'Email',
                hint: 'Enter Email',
                keyborad: TextInputType.emailAddress,
                controller: userAuthEmailController,
              ),

              SizedBox(height: size.height*0.06,),
              
              CustomBTN(label: 'Reset Password', onpressed: (){
                resetPassword(userAuthEmailController.text);
              })
            ],
          ),
        ),
      ),
    );
  }
}
