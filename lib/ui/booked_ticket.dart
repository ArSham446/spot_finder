import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spot_finder/controllers/soled_ticket_controller.dart';

class BookedTicket extends StatelessWidget {
  const BookedTicket({super.key});

  @override
  Widget build(BuildContext context) {
    SoledTicketController myTicketViewController =
        Get.put(SoledTicketController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booked Tickets'),
        centerTitle: true,
      ),
      body: Center(
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * .55,
            child: StreamBuilder(
              stream: myTicketViewController.getTicketData(),
              builder: (context, snapshot) {
                debugPrint(snapshot.data.toString());
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('No Tickets'),
                  );
                }
                return !snapshot.hasData
                    ? const Center(
                        child: Text('No Tickets'),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.docs.length,
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
                              child: TicketData(
                                  snapshot: snapshot.data!.docs[index].data()),
                            ),
                          );
                        },
                      );
              },
            )),
      ),
    );
  }
}

class TicketData extends StatelessWidget {
  final Map snapshot;
  const TicketData({
    super.key,
    required this.snapshot,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    SoledTicketController myTicketViewController =
        Get.find<SoledTicketController>();

    var outTime = snapshot['outTime'];
    var outTimeSplit = outTime.split(':');
    var outTimeHour = int.parse(outTimeSplit[0]);
    var outTimeMinute = int.parse(outTimeSplit[1]);
    var outTimeAmPm = outTimeSplit[2];
    var outTimeHour24 = outTimeAmPm == 'PM' ? outTimeHour + 12 : outTimeHour;
    debugPrint(outTimeHour24.toString());
    var bookingDate = snapshot['bookingDate'];
    var bookingDateSplit = bookingDate.split('/');
    var bookingDateYear = int.parse(bookingDateSplit[0]);
    debugPrint(bookingDateYear.toString());
    var bookingDateMonth = int.parse(bookingDateSplit[1]);
    var bookingDateDay = int.parse(bookingDateSplit[2]);
    var date = DateTime(bookingDateYear, bookingDateMonth, bookingDateDay,
        outTimeHour24, outTimeMinute);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
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
                      snapshot['parkingName'],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 12.0,
                      ),
                      child: ticketDetailsWidget(
                        'User Name',
                        snapshot['userName'],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 12.0,
                      ),
                      child: ticketDetailsWidget(
                        'Price',
                        snapshot['price'].toString(),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ticketDetailsWidget(
                      'Date',
                      snapshot['bookingDate'],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, right: 40.0),
                      child: ticketDetailsWidget(
                        'Vehicle No',
                        '${snapshot['vehicleNo']}'.toUpperCase(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, right: 40.0),
                      child: ticketDetailsWidget(
                        'Time',
                        '${snapshot['inTime']} - ${snapshot['outTime']} ',
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
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.orange),
                  foregroundColor: MaterialStateProperty.all(Colors.white

                      // Colors.white,
                      ),
                ),
                onPressed: () async {
                  await myTicketViewController.getTotalPrice(snapshot);
                },
                child: Text(snapshot['status'] == 'booked' &&
                        date.isAfter(DateTime.now())
                    ? 'Check In'
                    : snapshot['status'] == 'checkedIn'
                        ? 'Check Out'
                        : 'Ticket expired'),
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
