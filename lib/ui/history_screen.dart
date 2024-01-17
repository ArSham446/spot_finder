import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spot_finder/global/global.dart';
import 'package:spot_finder/widgets/ticket_view.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      index = 0;
                    });
                  },
                  style: ButtonStyle(
                      backgroundColor: index == 0
                          ? MaterialStateProperty.all(Colors.orange)
                          : MaterialStateProperty.all(Colors.white),
                      foregroundColor: index == 0
                          ? MaterialStateProperty.all(Colors.white)
                          : MaterialStateProperty.all(Colors.black)),
                  child: const Text('Soled Tickets'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      index = 1;
                    });
                  },
                  style: ButtonStyle(
                      backgroundColor: index == 1
                          ? MaterialStateProperty.all(Colors.orange)
                          : MaterialStateProperty.all(Colors.white),
                      foregroundColor: index == 1
                          ? MaterialStateProperty.all(Colors.white)
                          : MaterialStateProperty.all(Colors.black)),
                  child: const Text('Used Tickets'),
                ),
              ],
            ),
          ),
          Expanded(
              child: index == 0 ? method('ownerId') : method('customerId')),
        ],
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> method(String userType) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .where(userType, isEqualTo: firebaseAuth.currentUser!.uid)
            .where('status', isEqualTo: 'checkedOut')
            .snapshots(),
        builder: (context, snapshot) {
          debugPrint(snapshot.toString());
          if (!snapshot.hasData) {
            return const Center(
              child: Text('No Tickets'),
            );
          }

          //error
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 5, right: 10),
            child: ListView.separated(
              itemCount: snapshot.data!.docs.length,
              separatorBuilder: (context, index) {
                return const Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      thickness: 2.0,
                      color: Colors.black,
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                );
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Get.to(() => TicketView(
                        snapshot: snapshot.data!.docs[index].data()));
                  },
                  child: Container(
                    height: 70,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(50),
                          bottomRight: Radius.circular(50)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 5.0,
                          spreadRadius: 1.0,
                          offset: Offset(
                            0.0,
                            4.0,
                          ),
                        ),
                      ],
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                snapshot.data!.docs[index]['parkingName']
                                    .toString()
                                    .toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .7,
                                child: Text(
                                  snapshot.data!.docs[index]['parkingAddress']
                                      .toString(),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Rs:${snapshot.data!.docs[index]['price']} ',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }
}
