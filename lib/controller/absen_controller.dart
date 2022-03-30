import 'dart:convert';
import 'dart:io';
import 'package:geocoding/geocoding.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:absensiapp/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:safe_device/safe_device.dart';

class AbsenController extends GetxController {
  var biodata = Get.put(HomeController());
  var storage = const FlutterSecureStorage();
  final LocalAuthentication auth = LocalAuthentication();
  RxList riwayatAbsen = [].obs;
  RxString currentStat = 'Inisialisasi...'.obs;
  RxString lati = '0.0'.obs;
  RxString longi = '0.0'.obs;
    RxList<Placemark> placemark = <Placemark>[].obs;


  Future<File?> testCompressAndGetFile(File file, String targetPath) async {
    await FlutterExifRotation.rotateAndSaveImage(path: file.path);
    currentStat.value = 'Mengambil Foto...';
    var result = await FlutterImageCompress.compressAndGetFile(
        file.path, targetPath,
        quality: 20, format: CompressFormat.jpeg);

    return result;
  }

  Future submitAbsen(XFile imgpath) async {
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    currentStat.value = 'Verifikasi Biometrik...';
    (!canCheckBiometrics)
        ? Get.snackbar("Error", "Biometrics not supported")
        : null;
    currentStat.value = 'Verifikasi Perangkat...';
    bool canMockLocation = await SafeDevice.canMockLocation;
    if (canMockLocation) {
      Get.snackbar(
        'Error',
        'Device Kamu Terdeteksi Menggunakan Fake GPS',
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      );
    }
    // autentikasi fingerprint
    bool authenticated = await auth.authenticate(
        localizedReason: 'Verifikasi Sidik Jari Anda',
        useErrorDialogs: true,
        biometricOnly: true,
        androidAuthStrings: const AndroidAuthMessages(
          cancelButton: 'Batal',
          biometricSuccess: 'Sidik Jari Benar',
          goToSettingsButton: 'Pengaturan',
          goToSettingsDescription: 'Pengaturan',
          signInTitle: 'Verifikasi',
        ),
        stickyAuth: true);
    (!authenticated) ? Get.snackbar("Error", "Gagal Verifikasi") : null;

    // verifikasi wajah
    Directory tempDir = await getTemporaryDirectory();
    var file = await imgpath.readAsBytes();
    File pathh = await File('${tempDir.path}/image.jpeg').writeAsBytes(file);
    File? compress =
        await testCompressAndGetFile(pathh, '${tempDir.path}/imageC.jpeg');
    currentStat.value = 'Memverifikasi Wajah...';
    var ress = http.MultipartRequest(
        'POST', Uri.parse('https://restapi-face.herokuapp.com/verifikasi2'));
    ress.files.add(await http.MultipartFile.fromPath('file', compress!.path,
        filename: 'imageC.jpeg'));
    ress.fields['source'] = biodata.wajah.value;
    var resss = await ress.send();
    var ressss = await resss.stream.bytesToString();
    var verifikasi = json.decode(ressss);

    if (verifikasi['hasil'] >= 0.4) {
    return  Get.snackbar(
        'Sukses',
        'Verifikasi Wajah Gagal',
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.check),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Sukses',
        'Verifikasi Wajah Berhasil',
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.check),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      );
    }


    currentStat.value = 'Verifikasi Lokasi...';
        
    var token = await storage.read(key: 'token');
    currentStat.value = 'Upload Absensi...';
      var res = await http.post(
        Uri.parse('https://restapi-laravel.herokuapp.com/api/absen'),
        headers: {
          'Authorization': 'Bearer $token'
        },
        body: {
          'nis': biodata.nis.value,
          'lat': lati.value.toString(),
          'long':longi.value.toString(),
          'absen': 'H'
        });
    var data = await jsonDecode(res.body);
    if (res.statusCode != 200){
      Get.snackbar(
        'Error',
        data['message'],
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      );  
    } else {
      Get.snackbar(
        'Sukses',
        'Absensi Berhasil',
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.check),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      );
      await getRiwayat();
    }
    return data;
  }

  Future getRiwayat() async {
    riwayatAbsen.clear();
    var token = await storage.read(key: 'token');
    var url =
        "https://restapi-laravel.herokuapp.com/api/absen/" + biodata.nis.value;
    print(biodata.nis.value);
    var res = await http
        .get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
    var data = await jsonDecode(res.body);
    riwayatAbsen.value = data['absensi'];
  }
}
