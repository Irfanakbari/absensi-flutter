import 'dart:typed_data';
import 'package:absensiapp/controller/absen_controller.dart';
import 'package:absensiapp/main.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../controller/cameracontroller.dart';

class FaceDetectorView extends StatefulWidget {
  const FaceDetectorView({Key? key}) : super(key: key);

  @override
  _FaceDetectorViewState createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  final _absenC = Get.find<AbsenController>();
  late Uint8List file;
  CameraC controller = Get.find<CameraC>();
  RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    controller.controller =CameraController(
      cameras.last,
      ResolutionPreset.low,
    );
    controller.controller!.initialize().then((value) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    controller.controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
          body: (!isLoading.value)
              ? SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 50),
                        width: Get.width,
                        height: Get.height / 2,
                        child: Center(
                          child: Column(
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
                              SizedBox(
                                width: Get.width / 2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(700),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: CameraPreview(controller.controller!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: RaisedButton(
                            padding: const EdgeInsets.all(10),
                            color: Colors.green,
                            onPressed: () async {
                              isLoading.value = !isLoading.value;

                              XFile gambar = await controller.getImage();
                              await _absenC
                                  .submitAbsen(gambar)
                                  .then((value) {

                                    isLoading.value = !isLoading.value;
                                    Navigator.of(context).pop();
                                    
                                    });
                              
                            },
                                 
                            child: const Text(
                              'Absen',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoadingAnimationWidget.discreteCircle(
                          color: Colors.red, size: 20),
                      const SizedBox(height: 20),
                      Text(
                        _absenC.currentStat.value,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                )),
    );
  }
}
