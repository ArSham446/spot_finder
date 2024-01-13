import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spot_finder/global/global.dart';
import 'package:spot_finder/ui/bottomNavBar/details_screen.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  @override
  Widget build(BuildContext context) {
    debugPrint(firebaseAuth.currentUser!.uid);
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            'Favourites',
            style: TextStyle(
                color: Colors.black, fontSize: 26, fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black,
            ),
          )),
      body: Column(
        children: [
          SizedBox(
            height: size.height * 0.02,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(firebaseAuth.currentUser!.uid)
                    .collection('Favourite')
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Something went wrong'),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.data.docs.isEmpty) {
                    return const Center(
                      child: Text('No Parkings'),
                    );
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
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    height: size.height * 0.14,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Image.network(
                                        parkings[index]['imagesUrls'][0]),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: size.height * 0.05,
                                              width: size.width * 0.3,
                                              child: Text(
                                                parkings[index]['parkingName'],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                            SizedBox(
                                              height: size.height * 0.015,
                                            ),
                                            SizedBox(
                                              width: size.width * 0.3,
                                              height: size.height * 0.02,
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
                                        const Icon(
                                          Icons.favorite,
                                          color: Colors.red,
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
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
