import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spot_finder/controllers/home_controller.dart';
import 'package:spot_finder/global/global.dart';
import 'package:spot_finder/ui/auth/login_page.dart';
import 'package:spot_finder/ui/booked_ticket.dart';
import 'package:spot_finder/ui/favourute_screen.dart';
import 'package:spot_finder/ui/history_screen.dart';
import 'package:spot_finder/ui/ticket_view_screen.dart';
import 'package:spot_finder/widgets/customListile.dart';
import 'package:spot_finder/widgets/my_parks.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  HomeController homeController = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Obx(() => CircleAvatar(
                  radius: 50,
                  backgroundImage: homeController.userData['UserAvatarUrl'] ==
                          null
                      ? null
                      : NetworkImage(homeController.userData['UserAvatarUrl']),
                  child: homeController.userData['UserAvatarUrl'] == null
                      ? const Icon(Icons.person)
                      : null,
                )),
            title: Obx(() => Text(
                  homeController.userData['UserName'] ?? '',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600),
                )),
          ),
          SizedBox(
            height: size.height * 0.05,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MyParkings()));
            },
            child: CustomListile(
              tileIcon: Icons.location_on,
              tileTitle: "My Parking's",
            ),
          ),
          CustomListile(
              tileOnTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FavouriteScreen()));
              },
              tileIcon: Icons.favorite,
              tileTitle: 'My Favourite'),
          GestureDetector(
              onTap: () => Get.to(() => const MyTicketView()),
              child: CustomListile(
                  tileIcon: Icons.book_online, tileTitle: 'My Tckets')),
          GestureDetector(
              onTap: () => Get.to(() => const BookedTicket()),
              child: CustomListile(
                  tileIcon: Icons.book_online, tileTitle: 'Soled Tickets')),
          GestureDetector(
            onTap: () => Get.to(() => const HistoryScreen()),
            child: CustomListile(
              tileIcon: Icons.history,
              tileTitle: 'History',
            ),
          ),
          // CustomListile(tileIcon: Icons.info, tileTitle: 'About'),
          SizedBox(
            height: size.height * 0.08,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () async {
                  await SharedPreferences.getInstance().then((value) {
                    value.clear();
                  });
                  await firebaseAuth.signOut();
                  Get.offAll(() => const CustomerLogin());
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.orange, fontSize: 20),
                ),
              ),
              const Icon(
                Icons.logout,
                color: Colors.orange,
              )
            ],
          ),
        ],
      )),
    );
  }
}
