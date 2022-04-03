import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class BioController {
  var urlUpdate = 'https://restapi-laravel.herokuapp.com/api/siswa/';
  var storage = const FlutterSecureStorage();
  RxString currentStat = 'Inisialisasi...'.obs;

  Future updateWajah(int nim, XFile wajah) async {
    Directory tempDir = await getTemporaryDirectory();
    var token = await storage.read(key: 'token');
    currentStat.value = 'Mengambil Foto...';
    var file = await wajah.readAsBytes();
    File pathh = await File('${tempDir.path}/image.jpeg').writeAsBytes(file);
    File? compress =
        await testCompressAndGetFile(pathh, '${tempDir.path}/imageC.jpeg');
    currentStat.value = 'Memeriksa Wajah...';
    var wajahres = http.MultipartRequest(
        'POST', Uri.parse('https://face.kanadee.xyz/faceid'));
    wajahres.files
        .add(await http.MultipartFile.fromPath('file', compress!.path));
    var responAPI = await wajahres.send();
    var ressss = await responAPI.stream.bytesToString();
    var hasil = json.decode(ressss);
    currentStat.value = 'Uploading...';
    var respond = await http.put(Uri.parse(urlUpdate + nim.toString()), body: {
      'wajah': hasil['uid'],
    }, headers: {
      'Authorization': 'Bearer $token'
    });
    return respond.statusCode;
  }

  Future<File?> testCompressAndGetFile(File file, String targetPath) async {
    await FlutterExifRotation.rotateAndSaveImage(path: file.path);
    var result = await FlutterImageCompress.compressAndGetFile(
        file.path, targetPath,
        quality: 20, format: CompressFormat.jpeg);

    return result;
  }
}
