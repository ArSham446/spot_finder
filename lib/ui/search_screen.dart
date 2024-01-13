import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spot_finder/controllers/home_controller.dart';
import 'package:spot_finder/ui/bottomNavBar/details_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Search Screen',
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: Center(
            child: Obx(() => ListView.separated(
                  itemCount: homeController.searchedParkings.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    debugPrint(
                        homeController.searchedParkings[index]['parkingName']);
                    return Container(
                      color: index % 2 == 0 ? Colors.grey[200] : Colors.white,
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => DetailsScreen(
                              parking: homeController.searchedParkings[index]));
                        },
                        child: ListTile(
                          title: Text(homeController.searchedParkings[index]
                              ['parkingName']),
                          subtitle: Text(homeController.searchedParkings[index]
                              ['parkingAddress']),
                        ),
                      ),
                    );
                  },
                ))));
  }
}
