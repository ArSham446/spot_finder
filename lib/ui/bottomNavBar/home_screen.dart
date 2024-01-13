import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spot_finder/controllers/home_controller.dart';
import 'package:spot_finder/ui/favourute_screen.dart';
import 'package:spot_finder/ui/search_screen.dart';
import 'package:spot_finder/widgets/error_dialog.dart';

import 'details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.put(HomeController());
    debugPrint(homeController.userData['UserName']);
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Obx(() => CircleAvatar(
                        backgroundImage:
                            homeController.userData['UserAvatarUrl'] == null
                                ? null
                                : NetworkImage(
                                    homeController.userData['UserAvatarUrl']),
                        child: homeController.userData['UserAvatarUrl'] == null
                            ? const Icon(Icons.person)
                            : null,
                      )),
                  title: Obx(() => Text(
                        homeController.userData['UserName'] ?? '',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      )),
                  trailing: IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FavouriteScreen()));
                      },
                      icon: const Icon(Icons.favorite_outline)),
                ),
                SizedBox(
                  height: size.height * 0.03,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: size.width * 0.6,
                      child: CupertinoTextField(
                        placeholder: 'Serch Area',
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onChanged: (value) {
                          //check if the parking address contains the value
                          homeController.searchedParkings.value = homeController
                              .parkings
                              .where((element) => element['parkingAddress']
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .where((element) =>
                                  element['ownerId'] !=
                                  homeController.userData['UserId'])
                              .where(
                                  (element) => element['status'] == 'approved')
                              .toList();
                        },
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SearchScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Search'))
                  ],
                ),
                SizedBox(
                  height: size.height * 0.03,
                ),
                const Text(
                  'Popular Parkings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: size.height * 0.015,
                ),
                SizedBox(
                  height: size.height * 0.6,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('parkings')
                            .where(
                              'status',
                              isEqualTo: 'approved',
                            )
                            // .where('ownerId',
                            //     isEqualTo: firebaseAuth.currentUser!.uid)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                                child: Text('Something Went Wrong'));
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.data.docs.isEmpty) {
                            return const Center(
                                child: Text('No Parkings Available'));
                          }

                          return GridView.builder(
                              itemCount: snapshot.data.docs.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 20,
                                      crossAxisSpacing: 20,
                                      mainAxisExtent: 210),
                              itemBuilder: (BuildContext context, int index) {
                                var parkings = snapshot.data.docs;
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => DetailsScreen(
                                                  parking: parkings[index],
                                                )));
                                  },
                                  child: Material(
                                    elevation: 5,
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      height: size.height * 0.6,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            height: size.height * 0.14,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.black12,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Image.network(
                                              parkings[index]['imagesUrls'][0],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height:
                                                          size.height * 0.05,
                                                      width: size.width * 0.3,
                                                      child: Text(
                                                        parkings[index]
                                                            ['parkingName'],
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          size.height * 0.015,
                                                    ),
                                                    SizedBox(
                                                      width: size.width * 0.3,
                                                      height:
                                                          size.height * 0.02,
                                                      child: Text(
                                                        parkings[index]['city'],
                                                        style: const TextStyle(
                                                          color: Colors.black45,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                GestureDetector(
                                                  onTap: snapshot
                                                          .data
                                                          .docs[index]
                                                              ['favoritesList']
                                                          .contains(
                                                              homeController
                                                                      .userData[
                                                                  'UserId'])
                                                      ? () async {
                                                          await homeController
                                                              .removeFromFavorite(
                                                                  parkings,
                                                                  index)
                                                              .whenComplete(
                                                                  () async {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'parkings')
                                                                .doc(parkings[
                                                                        index]
                                                                    .id)
                                                                .update({
                                                              'favoritesList':
                                                                  FieldValue
                                                                      .arrayRemove([
                                                                homeController
                                                                        .userData[
                                                                    'UserId']
                                                              ])
                                                            }).whenComplete(() {
                                                              debugPrint(
                                                                  'Parking Removed from Favorite');
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder: (c) {
                                                                    return CustomErrorDialog(
                                                                      message:
                                                                          "Parking Removed from Favorites",
                                                                    );
                                                                  });
                                                            });
                                                          });
                                                        }
                                                      : () async {
                                                          await homeController
                                                              .addToFavorite(
                                                                  parkings,
                                                                  index)
                                                              .whenComplete(
                                                                  () async {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'parkings')
                                                                .doc(parkings[
                                                                        index]
                                                                    .id)
                                                                .update({
                                                              'favoritesList':
                                                                  FieldValue
                                                                      .arrayUnion([
                                                                homeController
                                                                        .userData[
                                                                    'UserId']
                                                              ])
                                                            }).whenComplete(() {
                                                              debugPrint(
                                                                  'Parking Added to Favorite');

                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder: (c) {
                                                                    return CustomErrorDialog(
                                                                      message:
                                                                          "Parking Added to Favorites",
                                                                    );
                                                                  });
                                                            });
                                                          });
                                                        },
                                                  child: Icon(
                                                    Icons.favorite_outline,
                                                    color: snapshot
                                                            .data
                                                            .docs[index][
                                                                'favoritesList']
                                                            .contains(
                                                                homeController
                                                                        .userData[
                                                                    'UserId'])
                                                        ? Colors.red
                                                        : Colors.black,
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              });
                        }),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
