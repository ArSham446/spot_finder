import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:spot_finder/global/global.dart';

class HomeController extends GetxController {
  RxBool isFavorit = false.obs;
  RxMap userData = {}.obs;
  RxList parkings = [].obs;
  RxList searchedParkings = [].obs;
  @override
  void onInit() async {
    super.onInit();
    getUserData();
    await getParkings();
  }

  void getUserData() {
    try {
      FirebaseFirestore.instance
          .collection('Users')
          .where('UserUID', isEqualTo: firebaseAuth.currentUser!.uid)
          .snapshots()
          .listen((event) {
        userData.value = event.docs[0].data();
        update();
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> addToFavorite(dynamic parkings, int index) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('Favourite')
          .doc()
          .set({
        'parkingName': parkings[index]['parkingName'],
        'parkingAddress': parkings[index]['parkingAddress'],
        'carSlots': parkings[index]['carSlots'],
        'bikeSlots': parkings[index]['bikeSlots'],
        'carPrice': parkings[index]['carPrice'],
        'bikePrice': parkings[index]['bikePrice'],
        'bycyclePrice': parkings[index]['bycyclePrice'],
        'bycycleSlots': parkings[index]['bycycleSlots'],
        'imagesUrls': parkings[index]['imagesUrls'],
        'latitude': parkings[index]['latitude'],
        'longitude': parkings[index]['longitude'],
        'city': parkings[index]['city'],
        'ownerId': parkings[index]['ownerId'],
        'parkingId': parkings[index]['parkingId'],
        'availableCarSlots': parkings[index]['availableCarSlots'],
        'availableBikeSlots': parkings[index]['availableBikeSlots'],
        'availableBycycleSlots': parkings[index]['availableBycycleSlots'],
        'status': parkings[index]['status']
      });
      isFavorit.value = true;
    } catch (e) {
      print(e);
    }
  }

  Future<void> searchParking(String search) async {
    try {
      FirebaseFirestore.instance
          .collection('parkings')
          .where('parkingAdress', isEqualTo: search)
          .snapshots()
          .listen((event) {
        userData.value = event.docs[0].data();
        update();
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> removeFromFavorite(dynamic parkings, int index) async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('Favourite')
          .where('parkingId', isEqualTo: parkings[index]['parkingId'])
          .get();
      await doc.docs[0].reference.delete();

      isFavorit.value = false;
    } catch (e) {
      print(e);
    }
  }

  Future<void> getParkings() async {
    await FirebaseFirestore.instance.collection('parkings').get().then((value) {
      parkings.value = value.docs;
      update();
    });
  }
}
