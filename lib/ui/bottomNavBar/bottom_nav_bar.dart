import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:spot_finder/services/notification_services.dart';
import 'package:spot_finder/ui/bottomNavBar/homeScreen.dart';
import 'package:spot_finder/ui/bottomNavBar/profle/profile.dart';
import 'package:spot_finder/ui/bottomNavBar/upload/add_parking.dart';

class CustomerBottomNavBar extends StatefulWidget {
  const CustomerBottomNavBar({super.key});

  @override
  _CustomerBottomNavBarState createState() => _CustomerBottomNavBarState();
}

class _CustomerBottomNavBarState extends State<CustomerBottomNavBar> {
  bool canPop = false;
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.w600);
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    AddParking(),
    ProfileScreen(),
  ];
  displayForegroundNotifications() {
    debugPrint('Customers App ///// displayForegroundNotifications');
    // FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Customers App /////Got a message whilst in the foreground!');
      print('Customers App ///// Message data: ${message.data}');

      if (message.notification != null) {
        print(
            'Customers App ///// Message also contained a notification: ${message.notification}');
        NotificationsServices.displayNotification(message);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    displayForegroundNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: canPop,
        onPopInvoked: (didPop) {
          if (didPop != true && _selectedIndex == 0) {
            showDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                      title: const Text('Are you sure you want to exit?'),
                      content: const Text(''),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text(
                            'No',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        CupertinoDialogAction(
                          onPressed: () {
                            SystemNavigator.pop();
                          },
                          child: const Text(
                            'Yes',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ));
          }
          setState(() {
            _selectedIndex = 0;
          });
        },
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: Colors.black,
              tabs: const [
                GButton(
                  icon: Icons.home_filled,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.add_circle,
                  text: 'Add Parking',
                ),
                GButton(
                  icon: Icons.person,
                  text: 'Profile',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
