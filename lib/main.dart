import 'package:absensiapp/controller/absen_controller.dart';
import 'package:absensiapp/controller/home_controller.dart';
import 'package:absensiapp/screen/splash.dart';
import 'package:absensiapp/controller/cameracontroller.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

  var status = await Permission.camera.status;
  if (status.isDenied) {
    await Permission.camera.request();
  }
// You can can also directly ask the permission about its status.
  if (await Permission.location.isDenied) {
    await Permission.location.request();
  }
  await Permission.mediaLibrary.request();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var homeC = Get.put(HomeController());
    CameraC controller = Get.put(CameraC());

    return const GetMaterialApp(title: 'Absensi App', home: Splash());
  }
}
