import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart' as poly;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:spot_finder/widgets/error_dialog.dart';

class GoogleMpController extends GetxController {
  String apiKey = 'AIzaSyCTBFI_TNSFAYrfqg5kUd9kUK3fZoLb2h4';

  GoogleMapController? googleMapController;
  RxSet<Marker> markers = <Marker>{}.obs;
  RxSet<Polyline> polylines = <Polyline>{}.obs;
  LatLng current = const LatLng(31.5204, 74.3587);
  LatLng? destination;
  TextEditingController userLocationController = TextEditingController();
  Position? position;

  void getDestination(LatLng destination) async {
    debugPrint('destination is not null');
    await getCurrentLocation().then((value) async {
      animateCamera(LatLng(value.latitude, value.longitude));
      await getRoute(LatLng(value.latitude, value.longitude), destination);
    });
  }

  //add marker
  // void addMarker(String name, LatLng latLng) {
  //   markers.add(
  //     Marker(
  //       markerId: const MarkerId('1'),
  //       position: current,
  //       infoWindow: const InfoWindow(title: 'Marker 1'),
  //       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),

  //     ),
  //   );
  // }
  void animateCamera(LatLng target) {
    googleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: 14.0,
        ),
      ),
    );
  }

  void latLangToAddress() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      current.latitude,
      current.longitude,
    );
    Placemark place = placemarks[0];
    String name = place.name.toString();
    String subLocality = place.subLocality.toString();
    String locality = place.locality.toString();
    String administrativeArea = place.administrativeArea.toString();
    String postalCode = place.postalCode.toString();
    String country = place.country.toString();
    String address =
        "$name, $subLocality, $locality, $administrativeArea, $postalCode, $country";
    debugPrint(address);
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

  Future<Position> getCurrentLocation() async {
    await Geolocator.isLocationServiceEnabled().then((value) {
      if (!value) {
        Get.dialog(
          CustomErrorDialog(
            message:
                "Location services are disabled. Please enable location services.",
          ),
        );
        return Future.error('Location services are disabled.');
      }
      return value;
    });

    await Geolocator.checkPermission().then((value) async {
      var permission = value;
      if (permission == LocationPermission.deniedForever) {
        Get.dialog(
          CustomErrorDialog(
            message:
                "Location permissions are permanently denied, we cannot request permissions.",
          ),
        );
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission().then((value) {
          permission = value;
          if (permission != LocationPermission.whileInUse &&
              permission != LocationPermission.always) {
            Get.dialog(
              CustomErrorDialog(
                message:
                    "Location permissions are denied. Please allow the app to access your location.",
              ),
            );
            return Future.error(
                'Location permissions are denied (actual value: $permission).');
          }
        });
      }
    });

    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    position = newPosition;

    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(
        position!.latitude,
        position!.longitude,
      );

      Placemark pMark = placeMarks[0];

      String completeAddress =
          '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';
      userLocationController.text = completeAddress;

      return newPosition;
    } catch (e) {
      debugPrint(e.toString());
      return newPosition;
    }
  }

  void addPolyline(Polyline polyline) {
    polylines.add(polyline);
  }

  Future<void> getRoute(LatLng start, LatLng destination) async {
    debugPrint('get route called');
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final String encodedPoints =
          jsonDecode(response.body)['routes'][0]['overview_polyline']['points'];
      final List<LatLng> decodedPoints = poly.PolylinePoints()
          .decodePolyline(encodedPoints)
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList();
      addPolyline(Polyline(
          polylineId: const PolylineId('1'),
          points: decodedPoints,
          color: Colors.orange,
          width: 5));
      debugPrint(response.body);
    } else {
      throw Exception('Failed to load route');
    }
  }
}
