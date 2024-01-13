import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spot_finder/controllers/search_places_controller.dart';

class SearchPlaces extends StatelessWidget {
  const SearchPlaces({super.key});

  @override
  Widget build(BuildContext context) {
    GoogleSreachPlaces googleSreachPlaces = Get.put(GoogleSreachPlaces());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Places'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body:  Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              controller: googleSreachPlaces.userSearchController,
              decoration: const InputDecoration(
                
                hintText: 'Search Places',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
                  ),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: googleSreachPlaces.suggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        googleSreachPlaces.userSearchController.text =
                            googleSreachPlaces.suggestions[index]['description'];
                      },
                      title: Text(
                        googleSreachPlaces.suggestions[index]['description'],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}