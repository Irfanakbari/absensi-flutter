import 'package:absensiapp/controller/absen_controller.dart';
import 'package:absensiapp/controller/home_controller.dart';
import 'package:absensiapp/screen/homepage.dart';
import 'package:absensiapp/screen/loginpage.dart';
import 'package:absensiapp/screen/splash.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final _homeC = Get.find<HomeController>();
  final _absenC = Get.put(AbsenController());

  Future login(String nis, String password) async {
    var storage = const FlutterSecureStorage();

    var dio = Dio();
    var niss = int.parse(nis);
    var response = await dio.post(
        'https://restapi-laravel.herokuapp.com/api/login',
        data: {'nis': niss, 'password': password});
    if (response.statusCode == 200) {
      await storage.write(key: 'token', value: response.data['access_token']);
      await storage.write(key: 'nis', value: nis);
      Get.offAll(const Splash());
    } else {
      Get.snackbar(
        'Error',
        'NIS atau Password Salah',
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future register(String nis, String nama, String password) async {
    var dio = Dio();
    var response = await dio.post(
        'https://restapi-laravel.herokuapp.com/api/register',
        data: {'nis': int.parse(nis), 'nama': nama, 'password': password});

    if (response.statusCode != 200) {
      Get.snackbar(
        'Error',
        "Pendaftaran Gagal",
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Sukses',
        "Pendaftaran Berhasil",
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.check),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      );
    }
    Get.offAll(const LoginPage());
  }

  Future<void> logout() async {
    var storage = const FlutterSecureStorage();
    var token = await storage.read(key: 'token');
    var dio = Dio();
    var resp = await dio
        .post('https://restapi-laravel.herokuapp.com/api/logout',
            options: Options(headers: {'Authorization': 'Bearer $token'}))
        .then((value) {
      if (value.statusCode == 200) {
        storage.delete(key: 'token');
        Get.snackbar('Logout', 'Berhasil Logout',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            borderRadius: 10,
            margin: const EdgeInsets.all(10),
            borderColor: Colors.green,
            borderWidth: 1,
            duration: const Duration(seconds: 2));

        Get.offAll(const LoginPage());
      }
    });
  }

  void cekLogin() async {
    var storage = const FlutterSecureStorage();
    var token = await storage.read(key: 'token');
    if (token == null) {
      Get.off(const LoginPage());
    } else {
      await _homeC.getBiodata();
      await _absenC.getRiwayat();
      Get.off(const HomePage());
    }
  }
}
