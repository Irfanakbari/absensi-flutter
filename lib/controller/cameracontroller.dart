import 'package:camera/camera.dart';
import 'package:get/get.dart';
import '../main.dart';

class CameraC extends GetxController{

  
  CameraController? controller = CameraController(
      cameras.last,
      ResolutionPreset.low,
      enableAudio: false,
    );

 

 Future<XFile> getImage() async {
    XFile file = await controller!.takePicture();
    return file;
  }
}