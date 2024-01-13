import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:get/get.dart';
import 'package:spot_finder/global/global.dart';
import 'package:spot_finder/ui/bottomNavBar/full_screen_view.dart';
import 'package:spot_finder/ui/date_time.dart';
import 'package:spot_finder/ui/google_map_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsScreen extends StatefulWidget {
  final dynamic parking;
  final bool? isOwner;
  const DetailsScreen({super.key, this.parking, this.isOwner});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Material(
      child: SafeArea(
        child: Scaffold(
            body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FullScreenView(
                                imagesList: widget.parking['imagesUrls'],
                              )));
                },
                child: Stack(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Swiper(
                        autoplay: true,
                        autoplayDelay: 3000,
                        pagination: const SwiperPagination(
                            builder: SwiperPagination.fraction),
                        itemBuilder: (context, index) {
                          debugPrint(
                              widget.parking['imagesUrls'].length.toString());
                          return Image(
                            image: NetworkImage(
                              widget.parking['imagesUrls'][index],
                            ),
                          );
                        },
                        itemCount: widget.parking['imagesUrls'].length,
                        // itemCount: imagesList.length,
                      ),
                    ),
                    Positioned(
                        left: 15,
                        top: 20,
                        child: CircleAvatar(
                          backgroundColor: Colors.black,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        )),
                  ],
                ),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  height: size.height * 0.02,
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.parking['parkingName'],
                          style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: size.height * 0.06,
                          width: size.width * 0.9,
                          child: Text(
                            widget.parking['parkingAddress'],
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [],
                    ),
                  ],
                ),
                Visibility(
                  visible: widget.isOwner == false ? true : false,
                  child: const SizedBox(
                    height: 30,
                  ),
                ),
                Visibility(
                  visible: widget.isOwner == false ? true : false,
                  child: Row(
                    children: [
                      const Text(
                        'Status: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Text(' ${widget.parking['status']}',
                          style: TextStyle(
                            color: widget.parking['status'] == 'approved'
                                ? Colors.green
                                : widget.parking['status'] == 'pending'
                                    ? Colors.orange
                                    : Colors.red,
                            fontSize: 16,
                          )),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  'Parking slots ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Cars:  ${widget.parking['availableCarSlots'].toString()}/${widget.parking['carSlots'].toString()}',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '   (Rs: ${widget.parking['carPrice'].toString()})',
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800),
                            )
                          ],
                        ),
                        Visibility(
                            visible: widget.isOwner == false ||
                                    widget.parking['ownerId'] ==
                                        firebaseAuth.currentUser!.uid
                                ? false
                                : true,
                            child: _bookButton('Book Car Slot')),
                      ],
                    ),
                    SizedBox(
                      height: size.height * 0.005,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Bikes:  ${widget.parking['availableBikeSlots'].toString()}/${widget.parking['bikeSlots'].toString()}',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '   (Rs: ${widget.parking['bikePrice'].toString()})',
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800),
                            )
                          ],
                        ),
                        Visibility(
                            visible: widget.isOwner == false ||
                                    widget.parking['ownerId'] ==
                                        firebaseAuth.currentUser!.uid
                                ? false
                                : true,
                            child: _bookButton('Book Bike Slot')),
                      ],
                    ),
                    SizedBox(
                      height: size.height * 0.005,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Cycles:  ${widget.parking['availableBycycleSlots'].toString()}/${widget.parking['bycycleSlots'].toString()}',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '   (Rs: ${widget.parking['bycyclePrice'].toString()})',
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800),
                            )
                          ],
                        ),
                        Visibility(
                            visible: widget.isOwner == false ||
                                    widget.parking['ownerId'] ==
                                        firebaseAuth.currentUser!.uid
                                ? false
                                : true,
                            child: _bookButton('Book Cycle Slot')),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.07,
                ),
                Visibility(
                  visible: widget.isOwner ?? true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.call,
                            color: Colors.orange,
                          ),
                          TextButton(
                              onPressed: () async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(widget.parking['ownerId'])
                                      .get()
                                      .then((value) {
                                    launch('tel:${value['UserPhone']}');
                                  });
                                } catch (e) {
                                  debugPrint(e.toString());
                                }
                              },
                              child: const Text(
                                'Call Now',
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20),
                              )),
                        ],
                      ),
                      Visibility(
                        visible: widget.isOwner ?? true,
                        child: Row(
                          children: [
                            TextButton(
                                onPressed: () {
                                  Get.to(() => GoogleMapScreen(
                                        lat: widget.parking['latitude'],
                                        lng: widget.parking['longitude'],
                                      ));
                                },
                                child: const Text(
                                  'Direction',
                                  style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20),
                                )),
                            const Icon(
                              Icons.directions,
                              color: Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.07,
                ),
                // Visibility(
                //   visible: widget.isOwner ?? false,
                //   child: Center(
                //     child: ElevatedButton(
                //         style: ButtonStyle(
                //           backgroundColor:
                //               MaterialStateProperty.all(Colors.orange),
                //           foregroundColor:
                //               MaterialStateProperty.all(Colors.white),
                //         ),
                //         onPressed: () {
                //           Get.to(() => UpdateParking(
                //                 parking: widget.parking,
                //               ));
                //         },
                //         child: const Text('Update Parking')),
                //   ),
                // ),
                // const SizedBox(
                //   height: 50,
                // ),
              ])
            ]),
          ),
        )),
      ),
    );
  }

  Widget _bookButton(String text) {
    return InkWell(
      onTap: widget.isOwner ?? true == false
          ? null
          : text == 'Book Car Slot'
              ? widget.parking['availableCarSlots'] == 0
                  ? null
                  : () {
                      Get.to(() => DateTimePage(
                            parking: widget.parking,
                            vehicleType: text,
                          ));
                    }
              : text == 'Book Bike Slot'
                  ? widget.parking['availableBikeSlots'] == 0
                      ? null
                      : () {
                          Get.to(() => DateTimePage(
                                parking: widget.parking,
                                vehicleType: text,
                              ));
                        }
                  : widget.parking['availableBycycleSlots'] == 0
                      ? null
                      : () {
                          Get.to(() => DateTimePage(
                                parking: widget.parking,
                                vehicleType: text,
                              ));
                        },
      child: Container(
          width: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.orange),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(text,
                  style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
            ),
          )),
    );
  }
}
