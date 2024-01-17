import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spot_finder/global/global.dart';

class GetTicketController extends GetxController {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController inTimeController = TextEditingController();
  final TextEditingController outTimeController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TimeOfDay? outTime;
  int remainingCarSlots = 0;
  int remainingBikeSlots = 0;
  int remainingBycycleSlots = 0;

  String? userName;

  @override
  void onInit() async {
    super.onInit();
    try {
      await _firestore
          .collection('Users')
          .doc(firebaseAuth.currentUser!.uid)
          .get()
          .then((value) {
        userName = value.data()!['UserName'];
        debugPrint(userName!);
        update();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> uploadToFirebase(dynamic parking, String vehicleType) async {
    if (vehicleType == 'Book Car Slot') {
      remainingCarSlots = parking['availableCarSlots'] - 1;
    } else if (vehicleType == 'Book Bike Slot') {
      remainingBikeSlots = parking['availableBikeSlots'] - 1;
    } else {
      remainingBycycleSlots = parking['availableBycycleSlots'] - 1;
    }
    try {
      debugPrint('uploading to firebase');
      var ref = await _firestore.collection('tickets').add({
        'bookingDate': dateController.text,
        'inTime': inTimeController.text,
        'outTime': outTimeController.text,
        'vehicleNo': vehicleController.text,
        'userName': userName,
        'parkingName': parking['parkingName'],
        'parkingAddress': parking['parkingAddress'],
        'customerId': firebaseAuth.currentUser!.uid,
        'status': 'booked',
        'ownerId': parking['ownerId'],
        'parkingId': parking['parkingId'],
        'vehicleType': vehicleType,
        // 'orignalOutTime': outTime!.toString(),
        'price': vehicleType == 'Book Car Slot'
            ? parking['carPrice']
            : vehicleType == 'Book Bike Slot'
                ? parking['bikePrice']
                : parking['bycyclePrice'],
      }).whenComplete(() async {
        debugPrint('uploaded to firebase');
        await _firestore
            .collection('parkings')
            .doc(parking['parkingId'])
            .update({
          vehicleType == 'Book Car Slot'
              ? 'availableCarSlots'
              : (vehicleType == 'Book Bike Slot'
                  ? 'availableBikeSlots'
                  : 'availableBycycleSlots'): vehicleType == 'Book Car Slot'
              ? remainingCarSlots
              : (vehicleType == 'Book Bike Slot'
                  ? remainingBikeSlots
                  : remainingBycycleSlots)
        });
      });
      await _firestore
          .collection('tickets')
          .doc(ref.id)
          .update({'ticketId': ref.id});
      debugPrint(ref.id);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
