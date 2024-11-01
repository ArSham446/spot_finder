import 'package:flutter/material.dart';

class TicketView extends StatelessWidget {
  final Map snapshot;
  const TicketView({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: Container(
            height: MediaQuery.of(context).size.height * .55,
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
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: TicketData(
              snapshot: snapshot,
            ),
          ),
        ),
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
            child: Column(
              children: [
                Row(
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
                          padding:
                              const EdgeInsets.only(top: 12.0, right: 40.0),
                          child: ticketDetailsWidget(
                            'Vehicle No',
                            '${snapshot['vehicleNo']}'.toUpperCase(),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 12.0, right: 40.0),
                          child: ticketDetailsWidget(
                            'Time',
                            '${snapshot['inTime']} - ${snapshot['outTime']} ',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, right: 40.0),
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width * .7,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Address',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                snapshot['parkingAddress'],
                                style: const TextStyle(color: Colors.black),
                                softWrap: true,
                              ),
                            )
                          ],
                        ),
                      )),
                ),
              ],
            )),
      ],
    );
  }

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
                  softWrap: true,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
