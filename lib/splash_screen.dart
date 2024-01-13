import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spot_finder/ui/auth/signup_page.dart';
import 'package:spot_finder/ui/bottomNavBar/bottom_nav_bar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () async {
      final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

      await prefs.then((SharedPreferences prefs) {
        if (prefs.getString('uid') != null) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const CustomerBottomNavBar()));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const CustomerSignup()));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Image.asset(
          'assets/images/spotFinderBanner.png',
          height: size.height * 0.098,
        ));
  }
}
