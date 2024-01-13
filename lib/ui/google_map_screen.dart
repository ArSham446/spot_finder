import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spot_finder/controllers/google_map_controller.dart';

class GoogleMapScreen extends StatelessWidget {
  final double? lat;
  final double? lng;
  const GoogleMapScreen({super.key, this.lat, this.lng});

  @override
  Widget build(BuildContext context) {
    GoogleMpController mapController = Get.put(GoogleMpController());
    mapController.getDestination(LatLng(lat!, lng!));
    return Scaffold(
      body: SafeArea(
          child: Obx(
        () => GoogleMap(
          //Map widget from google_maps_flutter package
          zoomGesturesEnabled: true, //enable Zoom in, out on map
          initialCameraPosition: CameraPosition(
            //innital position in map
            target: mapController.current, //initial position
            zoom: 14.0, //initial zoom level
          ),
          markers: mapController.markers.toSet(),
          polylines: mapController.polylines.toSet(), //markers to show on map
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          myLocationEnabled: true, //map type
          onMapCreated: (controller) {
            //method called when map is created
            mapController.googleMapController = controller;
          },
        ),
      )),
    );
  }
}
