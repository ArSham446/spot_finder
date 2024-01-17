import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:spot_finder/global/global.dart';

class SoledTicketController extends GetxController {
  RxList<Map<String, dynamic>> ticketData = <Map<String, dynamic>>[].obs;
  RxInt totalPrice = 0.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getTicketData() {
    return _firestore
        .collection('tickets')
        .where('ownerId', isEqualTo: firebaseAuth.currentUser!.uid)
        .where('status', isNotEqualTo: 'checkedOut')
        .snapshots();
  }

  Future<void> getTotalPrice(Map snapshot) async {
    //get price per hour
    int price = snapshot['price'];
    debugPrint('price: $price');
    //get in time
    var inTime = snapshot['inTime'];
    var inTimeSplit = inTime.split(':');
    var inTimeHour = int.parse(inTimeSplit[0]);
    var inTimeMinute = int.parse(inTimeSplit[1]);
    var inTimeAmPm = inTimeSplit[2];
    var inTimeHour24 = inTimeAmPm == 'PM' ? inTimeHour + 12 : inTimeHour;
    //get out time
    var outTime = snapshot['outTime'];
    var outTimeSplit = outTime.split(':');
    var outTimeHour = int.parse(outTimeSplit[0]);
    var outTimeMinute = int.parse(outTimeSplit[1]);
    var outTimeAmPm = outTimeSplit[2];
    var outTimeHour24 = outTimeAmPm == 'PM' ? outTimeHour + 12 : outTimeHour;
    //get booking date
    var bookingDate = snapshot['bookingDate'];
    var bookingDateSplit = bookingDate.split('/');
    var bookingDateYear = int.parse(bookingDateSplit[0]);
    var bookingDateMonth = int.parse(bookingDateSplit[1]);
    var bookingDateDay = int.parse(bookingDateSplit[2]);

    var fullinTime = DateTime(bookingDateYear, bookingDateMonth, bookingDateDay,
        inTimeHour24, inTimeMinute);
    var fulloutTime = DateTime(bookingDateYear, bookingDateMonth,
        bookingDateDay, outTimeHour24, outTimeMinute);
    var difference = fulloutTime.difference(fullinTime);
    var hours = difference.inHours;
    debugPrint('hours: $hours');
    var minutes = difference.inMinutes;
    debugPrint(minutes.toString());
    debugPrint(totalPrice.toString());

    if (snapshot['status'] == 'booked' && fulloutTime.isAfter(DateTime.now())) {
      try {
        await _firestore
            .collection('tickets')
            .doc(snapshot['ticketId'])
            .update({'status': 'checkedIn'});
      } catch (e) {
        debugPrint(e.toString());
      }
      Get.back();
    } else if (snapshot['status'] == 'booked' &&
        fulloutTime.isBefore(DateTime.now())) {
      await _firestore
          .collection('tickets')
          .doc(snapshot['ticketId'])
          .delete()
          .whenComplete(() async {
        await _firestore
            .collection('parkings')
            .doc(snapshot['parkingId'])
            .update({
          snapshot['vehicleType'] == 'Book Car Slot'
              ? 'availableCarSlots'
              : snapshot['vehicleType'] == 'Book Bike Slot'
                  ? 'availableBikeSlots'
                  : 'availableBycycleSlots': FieldValue.increment(1),
        });
      });
    } else if (snapshot['status'] == 'checkedIn') {
      int outTimeMinuteDifference =
          DateTime.now().difference(fulloutTime).inMinutes;
      int outTimeHourDifference =
          DateTime.now().difference(fulloutTime).inHours;
      if (outTimeMinuteDifference > 0) {
        debugPrint('fine');
        totalPrice.value =
            ((price * 1.1 * (hours + 1 + outTimeHourDifference))).toInt();
        Get.dialog(CupertinoAlertDialog(
          content: Text('Your total bill is Rs: ${totalPrice.value}'),
          actions: [
            dialogue(snapshot),
          ],
        ));
      } else {
        debugPrint('no fine');
        totalPrice.value = ((price * hours)).toInt();
        Get.dialog(CupertinoAlertDialog(
          content: Text('Your total bill is Rs: ${totalPrice.value}'),
          actions: [
            dialogue(snapshot),
          ],
        ));
      }
    }
  }

  CupertinoDialogAction dialogue(Map<dynamic, dynamic> snapshot) {
    return CupertinoDialogAction(
      child: const Text('Checkout'),
      onPressed: () async {
        try {
          await _firestore
              .collection('tickets')
              .doc(snapshot['ticketId'])
              .update({
            'status': 'checkedOut',
          }).whenComplete(() async {
            await _firestore
                .collection('parkings')
                .doc(snapshot['parkingId'])
                .update({
              snapshot['vehicleType'] == 'Book Car Slot'
                  ? 'availableCarSlots'
                  : snapshot['vehicleType'] == 'Book Bike Slot'
                      ? 'availableBikeSlots'
                      : 'availableBycycleSlots': FieldValue.increment(1),
            });
          });
        } catch (e) {
          debugPrint(e.toString());
        }
      },
    );
  }

  @override
  void onClose() {
    super.onClose();
    ticketData.clear();
  }
}
