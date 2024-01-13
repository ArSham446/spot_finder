// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spot_finder/controllers/add_parking_controller.dart';
import 'package:spot_finder/widgets/error_dialog.dart';

class CommonFunctions {
  AddParkingController addParkingController = Get.find<AddParkingController>();

  Future<Position> getCurrentLocation(BuildContext context) async {
    String completeAddress;
    bool serviceEnabled;
    Position? position;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showDialog(
        context: context,
        builder: (c) {
          return CustomErrorDialog(
            message:
                "Location services are disabled. Please enable them to continue.",
          );
        },
      );
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      showDialog(
        context: context,
        builder: (c) {
          return CustomErrorDialog(
            message:
                "Location permissions are permanently denied. Please allow the app to access your location in the device settings.",
          );
        },
      );
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        showDialog(
          context: context,
          builder: (c) {
            return CustomErrorDialog(
              message:
                  "Location permissions are denied. Please allow the app to access your location.",
            );
          },
        );
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    position = newPosition;
    addParkingController.latitude = position.latitude;
    addParkingController.longitude = position.longitude;
    debugPrint(position.toString());

    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark pMark = placeMarks[0];

      completeAddress =
          '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';

      addParkingController.parkingAddressController.text = completeAddress;
      addParkingController.city = '${pMark.thoroughfare} ${pMark.locality}';
      debugPrint(addParkingController.city);

      return newPosition;
    } catch (e) {
      debugPrint(e.toString());
      return newPosition;
    }
  }

  Future<void> requestPermissions() async {
    final permissions = [
      Permission.location,
      Permission.camera,
      Permission.storage,
    ];

    Map<Permission, PermissionStatus> status = await permissions.request();

    // Handle the permission statuses
    status.forEach((permission, permissionStatus) {
      if (permissionStatus.isGranted) {
        // Permission granted
        print('${permission.toString()} granted.');
      } else if (permissionStatus.isDenied) {
        // Permission denied
        print('${permission.toString()} denied.');
      } else if (permissionStatus.isPermanentlyDenied) {
        // Permission permanently denied
        print('${permission.toString()} permanently denied.');
      }
    });
  }
}
