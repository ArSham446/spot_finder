import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spot_finder/common_functions/common_functions.dart';
import 'package:spot_finder/controllers/add_parking_controller.dart';
import 'package:spot_finder/ui/bottomNavBar/bottom_nav_bar.dart';
import 'package:spot_finder/widgets/custom_btn.dart';
import 'package:spot_finder/widgets/custom_text_form_field.dart';
import 'package:spot_finder/widgets/error_dialog.dart';
import 'package:spot_finder/widgets/loading_dialog.dart';

class AddParking extends StatelessWidget {
  final dynamic parking;

  const AddParking({
    super.key,
    this.parking,
  });

  @override
  Widget build(BuildContext context) {
    AddParkingController addParkingController = Get.put(AddParkingController());

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
            'Add New Parking',
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
                  child: CustomTextFormField(
                    controller: addParkingController.parkingNameController,
                    label: 'Parking Name',
                    hint: 'Enter Parking Name',
                    keyborad: TextInputType.text,
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
                          builder: (context) => LoadingDialog(
                                message: 'Getting Location',
                                key: const Key('gettingLocation'),
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
                label: 'Save Parking',
                onpressed: () async {
                  if (addParkingController.images.isEmpty ||
                      addParkingController
                          .parkingAddressController.text.isEmpty ||
                      addParkingController.parkingNameController.text.isEmpty ||
                      addParkingController.bikePriceController.text.isEmpty ||
                      addParkingController.bikeSlotsController.text.isEmpty ||
                      addParkingController
                          .bycyclePriceController.text.isEmpty ||
                      addParkingController
                          .bycycleSlotsController.text.isEmpty ||
                      addParkingController.carPriceController.text.isEmpty ||
                      addParkingController.carSlotsController.text.isEmpty) {
                    showDialog(
                        context: context,
                        builder: (c) {
                          return CustomErrorDialog(
                            message:
                                "Please fill all the fields also add images",
                          );
                        });
                    return;
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return LoadingDialog(
                              message: 'Adding Parking',
                              key: const Key('addParking'));
                        });
                    await addParkingController.addParking().whenComplete(() {
                      Get.back();
                      showDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            content: const Text('Parking Added Successfully'),
                            actions: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 5, 15, 10),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.delete<AddParkingController>();
                                    Navigator.pop(context);
                                    Get.offAll(
                                        () => const CustomerBottomNavBar());
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      )),
                                  child: const Center(
                                      child: Text(
                                    'OK',
                                    style: TextStyle(color: Colors.white),
                                  )),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    });
                  }
                },
              ),
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
