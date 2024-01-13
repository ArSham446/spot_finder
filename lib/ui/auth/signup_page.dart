import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spot_finder/controllers/password_controller.dart';
import 'package:spot_finder/services/notification_services.dart';
import 'package:spot_finder/ui/bottomNavBar/bottom_nav_bar.dart';

import '../../controllers/controllers.dart';
import '../../global/global.dart';
import '../../widgets/custom_btn.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/loading_dialog.dart';
import 'login_page.dart';

class CustomerSignup extends StatefulWidget {
  const CustomerSignup({super.key});

  @override
  State<CustomerSignup> createState() => _CustomerSignupState();
}

class _CustomerSignupState extends State<CustomerSignup> {
  var obscureText = false;

  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  Position? position;

  String profileImage = "";
  String completeAddress = "";

  Future<void> requestPermissions() async {
    final permissions = [
      Permission.location,
      Permission.camera,
      Permission.storage,
    ];

    Map<Permission, PermissionStatus> status = await permissions.request();

    // Handle the permission statuses
    status.forEach((permission, permissionStatus) {
      if (permissionStatus.isGranted) {
        // Permission granted
        print('${permission.toString()} granted.');
      } else if (permissionStatus.isDenied) {
        // Permission denied
        print('${permission.toString()} denied.');
      } else if (permissionStatus.isPermanentlyDenied) {
        // Permission permanently denied
        print('${permission.toString()} permanently denied.');
      }
    });
  }

  // Future<void> _getImage() async
  // {
  //   imageXFile = await _picker.pickImage(source: ImageSource.gallery);
  //   setState(() {
  //     imageXFile;
  //   });
  // }

  Future<void> _getImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text(
            'Choose an option',
            style: TextStyle(color: Colors.orange),
          ),
          content: ListBody(
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                child: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImageFromSource(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                child: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImageFromSource(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImageFromSource(ImageSource source) async {
    var pickedImage = await _picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        imageXFile = pickedImage;
      });
    }
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showDialog(
        context: context,
        builder: (c) {
          return CustomErrorDialog(
            message:
                "Location services are disabled. Please enable them to continue.",
          );
        },
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      showDialog(
        context: context,
        builder: (c) {
          return CustomErrorDialog(
            message:
                "Location permissions are permanently denied. Please allow the app to access your location in the device settings.",
          );
        },
      );
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        showDialog(
          context: context,
          builder: (c) {
            return CustomErrorDialog(
              message:
                  "Location permissions are denied. Please allow the app to access your location.",
            );
          },
        );
        return;
      }
    }

    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      position = newPosition;
    });

    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(
        position!.latitude,
        position!.longitude,
      );

      Placemark pMark = placeMarks[0];

      setState(() {
        completeAddress =
            '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';
        userLocationController.text = completeAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> formValidation() async {
    if (imageXFile == null) {
      showDialog(
          context: context,
          builder: (c) {
            return CustomErrorDialog(
              message: "Please select an image.",
            );
          });
    } else {
      if (userAuthPasswordController.text ==
          userAuthConfirmPasswordController.text) {
        if (userAuthPasswordController.text.isNotEmpty &&
            userAuthEmailController.text.isNotEmpty &&
            userAuthNameController.text.isNotEmpty &&
            userPhoneController.text.isNotEmpty) {
          //start uploading image
          showDialog(
              context: context,
              builder: (c) {
                return LoadingDialog(
                  message: "Registering Account",
                );
              });

          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          fStorage.Reference reference = fStorage.FirebaseStorage.instance
              .ref()
              .child("Users")
              .child(fileName);
          fStorage.UploadTask uploadTask =
              reference.putFile(File(imageXFile!.path));
          fStorage.TaskSnapshot taskSnapshot =
              await uploadTask.whenComplete(() {});
          await taskSnapshot.ref.getDownloadURL().then((url) {
            profileImage = url;

            //save info to firestore
            authenticateSellerAndSignUp();
          });
        } else {
          showDialog(
              context: context,
              builder: (c) {
                return CustomErrorDialog(
                  message:
                      "Please write the complete required info for Registration.",
                );
              });
        }
      } else {
        showDialog(
            context: context,
            builder: (c) {
              return CustomErrorDialog(
                message: "Password do not match.",
              );
            });
      }
    }
  }

  void authenticateSellerAndSignUp() async {
    User? currentUser;

    try {
      await firebaseAuth
          .createUserWithEmailAndPassword(
        email: userAuthEmailController.text.trim(),
        password: userAuthPasswordController.text.trim(),
      )
          .then((auth) {
        currentUser = auth.user;
        debugPrint('User: $currentUser');
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
      debugPrint('Error: $e');
      Get.back();
    }
    if (currentUser != null) {
      SharedPreferences? sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.setString("uid", currentUser!.uid);
      saveDataToFirestore(currentUser!).whenComplete(() {
        Navigator.pop(context);
        //send user to homePage
        Get.offAll(() => const CustomerBottomNavBar());
      });
    }
  }

  Future saveDataToFirestore(User currentUser) async {
    String token = await NotificationsServices().getToken();
    try {
      FirebaseFirestore.instance.collection("Users").doc(currentUser.uid).set({
        "UserUID": currentUser.uid,
        "UserEmail": currentUser.email,
        "UserName": userAuthNameController.text.trim(),
        "UserAvatarUrl": profileImage,
        "UserPhone": userPhoneController.text.trim(),
        "token": token,
      });
    } catch (e) {
      showDialog(
          context: context,
          builder: (c) {
            return CustomErrorDialog(
              message: e.toString(),
            );
          });
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    PasswordController pController = Get.put(PasswordController());
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
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
                  height: size.height * 0.03,
                ),

                InkWell(
                  onTap: () {
                    _getImage();
                  },
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.1,
                    backgroundColor: Colors.grey.shade100.withOpacity(0.8),
                    backgroundImage: imageXFile == null
                        ? null
                        : FileImage(File(imageXFile!.path)),
                    child: imageXFile == null
                        ? Icon(
                            Icons.add_photo_alternate,
                            size: MediaQuery.of(context).size.width * 0.1,
                            color: Colors.orange,
                          )
                        : null,
                  ),
                ),
                SizedBox(
                  height: size.height * 0.03,
                ),
                Form(
                    child: Column(
                  children: [
                    CustomTextFormField(
                      label: 'Name',
                      hint: 'Enter Your Name',
                      keyborad: TextInputType.name,
                      controller: userAuthNameController,
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    CustomTextFormField(
                      label: 'Email',
                      hint: 'Enter Email',
                      keyborad: TextInputType.emailAddress,
                      controller: userAuthEmailController,
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    CustomTextFormField(
                      label: 'Phone',
                      hint: 'Enter Phone No.',
                      keyborad: TextInputType.phone,
                      controller: userPhoneController,
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Obx(() => CustomTextFormField(
                          passwordController: pController,
                          obscureText: pController.obscureText.value,
                          label: 'Password',
                          hint: 'Enter Password',
                          keyborad: TextInputType.visiblePassword,
                          icon: pController.obscureText.value
                              ? Icons.remove_red_eye
                              : Icons.visibility_off,
                          iconcolor: Colors.black,
                          controller: userAuthPasswordController,
                        )),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    Obx(() => CustomTextFormField(
                          passwordController: pController,
                          obscureText: pController.obscureText.value,
                          label: 'Confirm Password',
                          hint: 'Enter Same Password',
                          keyborad: TextInputType.visiblePassword,
                          icon: pController.obscureText.value
                              ? Icons.remove_red_eye
                              : Icons.visibility_off,
                          iconcolor: Colors.black,
                          controller: userAuthConfirmPasswordController,
                        )),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    CustomBTN(
                        label: 'Register',
                        onpressed: () {
                          formValidation();
                        }),
                    SizedBox(
                      height: size.height * 0.04,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already a user?'),
                        TextButton(
                            onPressed: () {
                              Get.delete<PasswordController>();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) => const CustomerLogin()));
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20),
                            ))
                      ],
                    ),
                  ],
                )),

                //   SizedBox(height: size.height*0.03,),
                //
                // TextButton(onPressed: (){}, child:   const Text('Privacy Policy', style: TextStyle(color: Colors.grey),))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
