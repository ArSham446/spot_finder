import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spot_finder/common_functions/common_functions.dart';
import 'package:spot_finder/controllers/add_parking_controller.dart';
import 'package:spot_finder/ui/bottomNavBar/bottom_nav_bar.dart';
import 'package:spot_finder/widgets/custom_btn.dart';
import 'package:spot_finder/widgets/custom_text_form_field.dart';

class UpdateParking extends StatelessWidget {
  final dynamic parking;

  const UpdateParking({
    super.key,
    this.parking,
  });

  @override
  Widget build(BuildContext context) {
    AddParkingController addParkingController = Get.put(AddParkingController());

    addParkingController.bikePriceController.text =
        parking['bikePrice'].toString();
    addParkingController.bikeSlotsController.text =
        parking['bikeSlots'].toString();
    addParkingController.bycyclePriceController.text =
        parking['bycyclePrice'].toString();
    addParkingController.bycycleSlotsController.text =
        parking['bycycleSlots'].toString();
    addParkingController.carPriceController.text =
        parking['carPrice'].toString();
    addParkingController.carSlotsController.text =
        parking['carSlots'].toString();
    addParkingController.parkingAddressController.text =
        parking['parkingAddress'].toString();
    addParkingController.parkingNameController.text =
        parking['parkingName'].toString();
    addParkingController.imagesUrls =
        RxList<String>.from(parking['imagesUrls'].cast<String>());

    CommonFunctions commonFunctions = CommonFunctions();
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.white,
          titleTextStyle: const TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
          title: const Text(
            'Edit Parking',
          )),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              TextButton(
                  onPressed: () async {
                    final XFile? image =
                        await addParkingController.pickImageFromGallery();
                    if (image != null) {
                      addParkingController.images.add(File(image.path));
                    }
                  },
                  child: const Text(
                    'Add photos',
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  )),
              SizedBox(
                height: size.height * 0.02,
              ),
              Obx(
                () => addParkingController.images.isEmpty
                    ? Container()
                    : SizedBox(
                        height: size.height * 0.2,
                        width: size.width * 0.9,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: addParkingController.images.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.file(
                                addParkingController.images[index],
                                height: size.height * 0.2,
                                width: size.width * 0.9,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
              ),
              SizedBox(
                  height: size.height * 0.06,
                  child: TextFormField(
                    controller: addParkingController.parkingNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Parking Name'),
                      hintText: 'Enter Parking Name',
                    ),
                  )),
              SizedBox(
                height: size.height * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      height: size.height * 0.06,
                      width: size.width * 0.44,
                      child: CustomTextFormField(
                        controller: addParkingController.carSlotsController,
                        label: 'Cars Slots',
                        hint: 'Total Slots',
                        keyborad: TextInputType.number,
                      )),
                  SizedBox(
                      height: size.height * 0.06,
                      width: size.width * 0.44,
                      child: CustomTextFormField(
                        controller: addParkingController.carPriceController,
                        label: 'Cars Price',
                        hint: 'Price per hour',
                        keyborad: TextInputType.number,
                      )),
                ],
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      height: size.height * 0.06,
                      width: size.width * 0.44,
                      child: CustomTextFormField(
                        label: 'Bikes Slots',
                        controller: addParkingController.bikeSlotsController,
                        hint: 'Total Slots',
                        keyborad: TextInputType.number,
                      )),
                  SizedBox(
                      height: size.height * 0.06,
                      width: size.width * 0.44,
                      child: CustomTextFormField(
                        label: 'Bikes Price',
                        controller: addParkingController.bikePriceController,
                        hint: 'Price per hour',
                        keyborad: TextInputType.number,
                      )),
                ],
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      height: size.height * 0.06,
                      width: size.width * 0.44,
                      child: CustomTextFormField(
                        label: 'Cycles Slots',
                        controller: addParkingController.bycycleSlotsController,
                        hint: 'Total Slots',
                        keyborad: TextInputType.number,
                      )),
                  SizedBox(
                      height: size.height * 0.06,
                      width: size.width * 0.44,
                      child: CustomTextFormField(
                        label: 'Cycles Price',
                        controller: addParkingController.bycyclePriceController,
                        hint: 'Price per hour',
                        keyborad: TextInputType.number,
                      )),
                ],
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              SizedBox(
                  height: size.height * 0.17,
                  child: CustomTextFormField(
                    readOnly: true,
                    maxLines: 5,
                    label: 'Parking Location',
                    controller: addParkingController.parkingAddressController,
                    hint: 'Enter Parking Location',
                    keyborad: TextInputType.text,
                    icon: Icons.location_on,
                    openMap: () async {
                      showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                                title: Text('wait location is loading'),
                              ));

                      await commonFunctions
                          .requestPermissions()
                          .whenComplete(() async {
                        await commonFunctions.getCurrentLocation(context);
                      }).whenComplete(() {
                        Get.back();
                      });
                    },
                    iconcolor: Colors.orange,
                  )),
              SizedBox(
                height: size.height * 0.07,
              ),
              CustomBTN(
                  label: 'Update Parking',
                  onpressed: () async {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return SizedBox(
                            height: size.height * 0.1,
                            width: size.width * 0.1,
                            child: const AlertDialog(
                              title: Text('Updating Parking'),
                            ),
                          );
                        });
                    await addParkingController
                        .updateParking(parking)
                        .whenComplete(() {
                      Get.back();
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Parking Updated Successfully'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Get.delete<AddParkingController>();

                                    Get.offAll(
                                        () => const CustomerBottomNavBar());
                                  },
                                  child: const Text('OK'))
                            ],
                          );
                        },
                      );
                    });
                  }),
              SizedBox(
                height: size.height * 0.07,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
