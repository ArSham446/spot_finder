import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:spot_finder/global/global.dart';

class MyTicketView extends StatelessWidget {
  const MyTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    TicketViewController myTicketViewController =
        Get.put(TicketViewController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
        centerTitle: true,
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * .7,
          child: Obx(
            () => myTicketViewController.ticketData.isEmpty
                ? const Center(
                    child: Text('No Tickets'),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: myTicketViewController.ticketData.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(
                        width: 10.0,
                      );
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Container(
                          decoration: const BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 10.0,
                                spreadRadius: 1.0,
                                offset: Offset(
                                  4.0,
                                  4.0,
                                ),
                              ),
                            ],
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                          ),
                          child: TicketData(index: index),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class TicketData extends StatelessWidget {
  final int index;
  const TicketData({
    super.key,
    required this.index,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    TicketViewController myTicketViewController =
        Get.find<TicketViewController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120.0,
                height: 25.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(width: 1.0, color: Colors.green),
                ),
                child: const Center(
                  child: Text(
                    'Spot Finder',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 20.0, left: 12.0),
          child: Text(
            'Parking Ticket',
            style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ticketDetailsWidget(
                      'Parking Name',
                      myTicketViewController.ticketData[index]['parkingName'],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 12.0,
                      ),
                      child: ticketDetailsWidget(
                        'User Name',
                        myTicketViewController.ticketData[index]['userName'],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 12.0,
                      ),
                      child: ticketDetailsWidget(
                        'Price',
                        myTicketViewController.ticketData[index]['price']
                            .toString(),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ticketDetailsWidget(
                      'Date',
                      myTicketViewController.ticketData[index]['bookingDate'],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, right: 40.0),
                      child: ticketDetailsWidget(
                        'Vehicle No',
                        '${myTicketViewController.ticketData[index]['vehicleNo']}'
                            .toUpperCase(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, right: 40.0),
                      child: ticketDetailsWidget(
                        'Time',
                        '${myTicketViewController.ticketData[index]['inTime']} - ${myTicketViewController.ticketData[index]['outTime']} ',
                      ),
                    ),
                  ],
                ),
              ],
            )),
        Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 30.0, right: 30.0),
          child: SizedBox(
            // QrImage,
            child: Center(
              child: QrImageView(
                data: myTicketViewController.ticketData[index]
                        ['parkingAddress'] ??
                    'no data',
                version: QrVersions.auto,
                size: 170.0,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
//

Widget ticketDetailsWidget(
  String firstTitle,
  String firstDesc,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              firstTitle,
              style: const TextStyle(color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                firstDesc,
                style: const TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
    ],
  );
}

class TicketViewController extends GetxController {
  RxList<Map<String, dynamic>> ticketData = <Map<String, dynamic>>[].obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  onInit() {
    super.onInit();
    geMyTickets();
  }

  Future<void> geMyTickets() async {
    try {
      var doc = await _firestore
          .collection('tickets')
          .where('customerId', isEqualTo: firebaseAuth.currentUser!.uid)
          .get();
      ticketData.value = doc.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
