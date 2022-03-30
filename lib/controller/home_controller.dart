import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:safe_device/safe_device.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  late RxString nama = "".obs;
  late RxString nis = "".obs;
  late RxString ip = "".obs;
  late RxString jamBuka = "".obs;
  late RxString jamTutup = "".obs;
  late RxString wajah = "".obs;
  late RxBool isAbsen = false.obs;

  HomeController() {
    initSys();
    getBiodata();
  }

  Future<void> initSys() async {
    bool isJailBroken = await SafeDevice.isJailBroken;

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (isJailBroken) {
      Get.snackbar(
        'Error',
        'Device Kamu Terdeteksi Sudah di Root',
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      );
    }
  }

  Future<void> getBiodata() async {
    String localeName = "id_ID"; // "en_US" etc.
    initializeDateFormatting(localeName);
    var storage = const FlutterSecureStorage();
    var token = await storage.read(key: 'token');
    var id = await storage.read(key: 'nis');

    print("id : " + id.toString());
    await http.get(
        Uri.parse(
            'https://restapi-laravel.herokuapp.com/api/siswa/' + id.toString()),
        headers: {
          'Authorization': 'Bearer ' + token.toString()
        }).then((values) {
      var value = jsonDecode(values.body);
      jamBuka.value = DateFormat('HH:mm', 'id_ID').format(
          DateFormat('HH:mm', 'id_ID').parse(value['data']['jam_buka']));
      jamTutup.value = DateFormat('HH:mm', 'id_ID').format(
          DateFormat('HH:mm', 'id_ID').parse(value['data']['jam_tutup']));
      nama.value = value['data']['nama'];
      nis.value = value['data']['nis'].toString();
      wajah.value = value['data']['wajah'] ?? '';
      isAbsen.value = value['data']['isAbsen'];
    });
  }
}
