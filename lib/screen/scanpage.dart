import 'package:absensiapp/controller/bio_controller.dart';
import 'package:absensiapp/controller/cameracontroller.dart';
import 'package:absensiapp/controller/home_controller.dart';
import 'package:absensiapp/main.dart';
import 'package:absensiapp/screen/homepage.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:restart_app/restart_app.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final _cameraC = Get.put(CameraC());
  final _biodataC = Get.find<HomeController>();
  final _bioC = Get.put(BioController());
  RxBool isloading = false.obs;

  @override
  void initState() {
    super.initState();
    _cameraC.controller =CameraController(
      cameras.last,
      ResolutionPreset.low,
    );
    _cameraC.controller!.initialize().then((value) => setState(() {}));
  }

  @override
  void dispose()async {
    super.dispose();
    _cameraC.controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(()=> Scaffold(
          body:
          (!isloading.value)?
           Stack(
        children: [
          SizedBox(
            width: Get.width,
            height: Get.height,
            child: CameraPreview(_cameraC.controller!),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Posisikan Wajah Anda di Tengah Lingkaran',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  RaisedButton(
                    padding: const EdgeInsets.all(10),
                    color: Colors.green,
                    onPressed: () async {
                      isloading.value = !isloading.value;
                     XFile gambar = await _cameraC.getImage();
                      _bioC.updateWajah(int.parse(_biodataC.nis.value),gambar).then((value) {
                      isloading.value = !isloading.value;
                        if (value!= 200){
                          Get.snackbar('Gagal', 'Gagal Merekam Data',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red,
                              borderRadius: 10,
                              margin: const EdgeInsets.all(10),
                              borderColor: Colors.red,
                        
                              );
                        } else {
                       
                          Restart.restartApp();
                        }
                      });
                    
    
                    },
                    child: const Text(
                      'Absen',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ):Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoadingAnimationWidget.discreteCircle(
                          color: Colors.red, size: 20),
                      const SizedBox(height: 20),
                      Text(
                        _bioC.currentStat.value,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                )),
    );
  }
}
