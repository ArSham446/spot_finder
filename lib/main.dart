import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spot_finder/services/notification_services.dart';
import 'package:spot_finder/splash_screen.dart';

import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
      "Customers App ///// Handling a background message: ${message.messageId}");
  debugPrint("Handling a background message: ${message.notification!.title}");
  debugPrint("Handling a background message: ${message.notification!.body}");
  debugPrint("Handling a background message: ${message.data}");
  debugPrint("Customers App ///// Handling a background message: ${message.data['key1']}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    } else {
      debugPrint('Permission already granted');
    }
  });

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationsServices notificationsServices = NotificationsServices();
  NotificationsServices.createNotificationChannelAndInitialize();
  notificationsServices.getToken();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    NotificationsServices.displayNotification(initialMessage);
  }

  runApp(const SpotFinderApp());
}

class SpotFinderApp extends StatefulWidget {
  const SpotFinderApp({super.key});

  @override
  State<SpotFinderApp> createState() => _SpotFinderAppState();
}

class _SpotFinderAppState extends State<SpotFinderApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: MaterialApp(
          title: 'Spot Finder',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.orange,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                elevation: 0,
                titleTextStyle: TextStyle(color: Colors.black)),
          ),
          home: const SplashScreen()),
    );
  }
 }
