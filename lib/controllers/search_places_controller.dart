import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class GoogleSreachPlaces extends GetxController{

  TextEditingController userSearchController = TextEditingController();
  final  String _sessionToken = const Uuid().v4();
  RxList<dynamic> suggestions = <dynamic>[].obs;
  String apiKey = 'AIzaSyCTBFI_TNSFAYrfqg5kUd9kUK3fZoLb2h4';

  @override
  void onInit() {
    super.onInit();
    userSearchController.addListener(() {
      if (userSearchController.text.isNotEmpty) {
        getSuggestions(userSearchController.text);
      }
    });
  }
 

 void getSuggestions(String input) async {
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
   String apiKey = 'AIzaSyCTBFI_TNSFAYrfqg5kUd9kUK3fZoLb2h4';
    String type = '(regions)';
    String request =
        '$baseURL?input=$input&key=$apiKey&sessiontoken=$_sessionToken&components=country:pk&type=$type';
    var response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
        suggestions.value = jsonDecode(response.body.toString())['predictions'];
      print(response.body);
    } else {
      throw Exception('Failed to load predictions');
    }
   
  }
 
 

  

}