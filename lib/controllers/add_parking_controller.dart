import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spot_finder/global/global.dart';

class AddParkingController extends GetxController {
  TextEditingController parkingNameController = TextEditingController();
  TextEditingController parkingAddressController = TextEditingController();
  TextEditingController carSlotsController = TextEditingController();
  TextEditingController bikeSlotsController = TextEditingController();
  TextEditingController carPriceController = TextEditingController();
  TextEditingController bikePriceController = TextEditingController();
  TextEditingController bycyclePriceController = TextEditingController();
  TextEditingController bycycleSlotsController = TextEditingController();
  RxList<File> images = <File>[].obs;
  List<String> imagesUrls = <String>[];
  String? city;
  double? latitude;
  double? longitude;

  // select images from gallery
  // RxList<String> images = <String>[].obs;
  Future<XFile?> pickImageFromGallery() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      return image;
    } else {
      return null;
    }
  }

  // select images from camera
  Future<XFile?> pickImageFromCamera() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      return image;
    } else {
      return null;
    }
  }

  Future<void> addParking() async {
    // upload images to firebase storage
    try {
      for (int i = 0; i < images.length; i++) {
        var ref = FirebaseStorage.instance
            .ref()
            .child('parkingImages/$parkingNameController/${images[i].path}');
        UploadTask uploadTask = ref.putFile(images[i]);
        await uploadTask.whenComplete(() async {
          String imageUrl = await ref.getDownloadURL();
          imagesUrls.add(imageUrl);
          debugPrint(imagesUrls.toString());
        });
      }
      // add parking to firebase
      final ref = await FirebaseFirestore.instance.collection('parkings').add({
        'parkingName': parkingNameController.text,
        'parkingAddress': parkingAddressController.text,
        'carSlots': int.parse(carSlotsController.text),
        'bikeSlots': int.parse(bikeSlotsController.text),
        'carPrice': int.parse(carPriceController.text),
        'bikePrice': int.parse(bikePriceController.text),
        'bycyclePrice': int.parse(bycyclePriceController.text),
        'bycycleSlots': int.parse(bycycleSlotsController.text),
        'imagesUrls': imagesUrls,
        'latitude': latitude,
        'longitude': longitude,
        'city': city,
        'ownerId': firebaseAuth.currentUser!.uid,
        'availableCarSlots': int.parse(carSlotsController.text),
        'availableBikeSlots': int.parse(bikeSlotsController.text),
        'availableBycycleSlots': int.parse(bycycleSlotsController.text),
        'favoritesList': [],
        'status': 'pending'
      });
      await ref.update({'parkingId': ref.id});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateParking(dynamic parking) async {
    debugPrint(parkingNameController.text);
    // upload images to firebase storage
    try {
      for (int i = 0; i < images.length; i++) {
        {
          var ref = FirebaseStorage.instance
              .ref()
              .child('parkingImages/$parkingNameController/${images[i].path}');
          UploadTask uploadTask = ref.putFile(images[i]);
          await uploadTask.whenComplete(() async {
            String imageUrl = await ref.getDownloadURL();
            imagesUrls.add(imageUrl);
            debugPrint(imagesUrls.toString());
          });
        }
        // add parking to firebase
        await FirebaseFirestore.instance
            .collection('parkings')
            .doc(parking['parkingId'])
            .update({
          'parkingName': parkingNameController.text,
          'parkingAddress': parkingAddressController.text,
          'carSlots': int.parse(carSlotsController.text),
          'bikeSlots': int.parse(bikeSlotsController.text),
          'carPrice': int.parse(carPriceController.text),
          'bikePrice': int.parse(bikePriceController.text),
          'bycyclePrice': int.parse(bycyclePriceController.text),
          'bycycleSlots': int.parse(bycycleSlotsController.text),
          'imagesUrls': imagesUrls,
          'latitude': latitude ?? parking['latitude'],
          'longitude': longitude ?? parking['longitude'],
          'city': city ?? parking['city'],
          'ownerId': firebaseAuth.currentUser!.uid,
          'availableCarSlots': int.parse(carSlotsController.text),
          'availableBikeSlots': int.parse(bikeSlotsController.text),
          'availableBycycleSlots': int.parse(bycycleSlotsController.text),
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
