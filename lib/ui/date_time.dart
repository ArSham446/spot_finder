import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:spot_finder/controllers/get_ticket_controller.dart';
import 'package:spot_finder/ui/bottomNavBar/bottom_nav_bar.dart';
import 'package:spot_finder/widgets/custom_text_form_field.dart';
import 'package:spot_finder/widgets/error_dialog.dart';
import 'package:spot_finder/widgets/loading_dialog.dart';

class DateTimePage extends StatefulWidget {
  final dynamic parking;
  final String vehicleType;

  const DateTimePage(
      {super.key, required this.parking, required this.vehicleType});

  @override
  DateTimePageState createState() => DateTimePageState();
}

class DateTimePageState extends State<DateTimePage> {
  final GetTicketController getTicketController =
      Get.put(GetTicketController());

  Future<void> sendNotification(String sid) async {
    debugPrint('sid:$sid');
    String token = '';

    try {
       await FirebaseFirestore.instance
          .collection('Users')
          .doc(sid)
          .get()
          .then((value) => token = value.data()!['token']);
    } catch (e) {
      debugPrint(e.toString());
    }

    debugPrint('token:$token');

    var data = {
      "notification": {
        "title": "Someone Booked Your Parking",
        "body": widget.vehicleType,
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "sound": "default"
      },
      "priority": "high",
      "to": token
    };
    try {
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          body: jsonEncode(data),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization':
                'key=AAAA5WAIP5s:APA91bG2nI1ydw_eqUn5VuCJMEYZDJbIa3GF6o5Z9XlwXku3Vl2E57WupHnOdDiMoM-skrmKyqm1hNWsEa_oNr-veKPTLFPLLZWIpcRUoXDdBIUuDZXiCSCuTgs9VD6OrxqCKHlcXV04'
          });
      debugPrint('notification sent');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
                primary: Colors.orange, surface: Colors.white),
          ),
          child: child!,
        );
      },
    );
    picked == null
        ? getTicketController.dateController.text = ''
        : getTicketController.dateController.text =
            '${picked.year}/${picked.month}/${picked.day}';
  }

  Future<void> _selectInTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
                primary: Colors.orange, surface: Colors.white),
          ),
          child: child!,
        );
      },
    );
    String period = '';
    int hour = 0;
    if (picked != null) {
      period = picked.hour >= 12 ? 'PM' : 'AM';
      hour = picked.hour > 12 ? picked.hour - 12 : picked.hour;
      getTicketController.inTimeController.text =
          '$hour:${picked.minute}:$period';
    } else {
      period = '';
      hour = 0;
    }
  }

  Future<void> _selectOutTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
                primary: Colors.orange, surface: Colors.white),
          ),
          child: child!,
        );
      },
    );
    String period = '';
    int hour = 0;
    if (picked != null) {
      period = picked.hour >= 12 ? 'PM' : 'AM';
      hour = picked.hour > 12 ? picked.hour - 12 : picked.hour;
      getTicketController.outTimeController.text =
          '$hour:${picked.minute}:$period';
    } else {
      period = '';
      hour = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50.0, left: 20, right: 20),
                child: Form(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomTextFormField(
                        hint: 'Date',
                        onTap: _selectDate,
                        label: 'Date',
                        controller: getTicketController.dateController,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextFormField(
                        hint: 'In Time',
                        onTap: _selectInTime,
                        label: 'In Time',
                        controller: getTicketController.inTimeController,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextFormField(
                        hint: 'Out Time',
                        onTap: _selectOutTime,
                        label: 'Out Time',
                        controller: getTicketController.outTimeController,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextFormField(
                        hint: 'Vehicle Number',
                        label: 'Vehicle Number',
                        controller: getTicketController.vehicleController,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.orange),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () async {
                  // showDialog(
                  //     context: context,
                  //     builder: (c) => LoadingDialog(
                  //           message: 'Booking Ticket',
                  //         ));
                  if (getTicketController.dateController.text.isEmpty) {
                    showDialog(
                        context: context,
                        builder: (c) => CustomErrorDialog(
                              message: 'Please Select Date',
                            ));
                  } else if (getTicketController
                      .inTimeController.text.isEmpty) {
                    showDialog(
                        context: context,
                        builder: (c) => CustomErrorDialog(
                              message: 'Please Select In Time',
                            ));
                  } else if (getTicketController
                      .outTimeController.text.isEmpty) {
                    showDialog(
                        context: context,
                        builder: (c) => CustomErrorDialog(
                              message: 'Please Select Out Time',
                            ));
                  } else if (getTicketController
                      .vehicleController.text.isEmpty) {
                    showDialog(
                        context: context,
                        builder: (c) => CustomErrorDialog(
                              message: 'Please Enter Vehicle Number',
                            ));
                  } else if (getTicketController
                          .dateController.text.isNotEmpty &&
                      getTicketController.inTimeController.text.isNotEmpty &&
                      getTicketController.outTimeController.text.isNotEmpty &&
                      getTicketController.vehicleController.text.isNotEmpty) {
                    showDialog(
                        context: context,
                        builder: (c) => LoadingDialog(
                              message: 'Booking Ticket',
                            ));
                    await getTicketController
                        .uploadToFirebase(widget.parking, widget.vehicleType)
                        .whenComplete(() async {
                      await sendNotification(widget.parking['ownerId'])
                          .whenComplete(() {
                        Get.back();
                        showDialog(
                            context: context,
                            builder: (c) => CupertinoAlertDialog(
                                  content:
                                      const Text('Ticket Booked Successfully'),
                                  actions: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 5, 15, 10),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Get.off(const CustomerBottomNavBar());
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            )),
                                        child: const Center(
                                            child: Text(
                                          'OK',
                                          style: TextStyle(color: Colors.white),
                                        )),
                                      ),
                                    ),
                                  ],
                                ));
                      });
                    });
                  }
                },
                child: const Text('Get Your Ticket Now'),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
