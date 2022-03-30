import 'package:absensiapp/controller/absen_controller.dart';
import 'package:absensiapp/controller/home_controller.dart';
import 'package:absensiapp/controller/login_controller.dart';
import 'package:absensiapp/screen/absenpage.dart';
import 'package:absensiapp/screen/scanpage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _homeC = Get.find<HomeController>();
  final _absenC = Get.find<AbsenController>();
  RxBool isClose = false.obs;
  RxBool isLoading = false.obs;

void streamLoc(){
  Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    ),
  ).listen((Position position) async {
    _absenC.lati.value = position.latitude.toString();
    _absenC.longi.value = position.longitude.toString();
    _absenC.placemark.value =
        await placemarkFromCoordinates(position.latitude, position.longitude);
  });
}

  @override
  void initState() {
    super.initState();
    var format = DateFormat("HH:mm");
    var jamBuka = format.parse(_homeC.jamBuka.toString());
    var jamTutup = format.parse(_homeC.jamTutup.toString());
    var now = format.parse(format.format(DateTime.now()));
    if (now.isAfter(jamBuka) && now.isBefore(jamTutup)) {
      isClose.value = false;
    } else {
      isClose.value = true;
    }
    streamLoc();
   
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: const Color.fromRGBO(56, 231, 106, 1),
        body: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sistem Absensi',
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        color: Colors.red,
                        highlightColor: Colors.red,
                        icon: const Icon(Icons.exit_to_app),
                        onPressed: () {
                          LoginController().logout();
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              Image.network('https://i.ibb.co/NCJ8L9v/ftt.jpg')
                                  .image,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _homeC.nama.value,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'NISN: ' + _homeC.nis.value,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 20),
                            (_absenC.placemark.isNotEmpty)
                                ? Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.white,
                                      ),
                                      Text(
                                       _absenC.placemark[0].locality ?? 'Not Found',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      )
                                    ],
                                  )
                                : const Text(
                                    'Not Found Location',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    color: Color.fromRGBO(252, 251, 252, 1)),
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 40, left: 30, right: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 206, 206, 206),
                                  blurRadius: 9,
                                  blurStyle: BlurStyle.normal,
                                  spreadRadius: 1,
                                  offset: Offset(
                                    2,
                                    8,
                                  ),
                                ),
                              ]),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Absensi',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('EEEE', 'id_ID')
                                              .format(DateTime.now()) +
                                          ", " +
                                          DateTime.now().day.toString() +
                                          '/' +
                                          DateTime.now().month.toString() +
                                          '/' +
                                          DateTime.now().year.toString(),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  _homeC.jamBuka.value +
                                      " - " +
                                      _homeC.jamTutup.value,
                                  style: const TextStyle(
                                    fontSize: 40,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                ),
                                (!_homeC.isAbsen.value)?
                                const Text(
                                  'Anda Belum Absen',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ):const Text(
                                  'Anda Sudah Absen',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                ),
                                const SizedBox(height: 20),
                                (isClose.value)
                                    ?
                                    // button
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        height: 50,
                                        child: RaisedButton(
                                          color: const Color.fromRGBO(
                                              56, 231, 106, 1),
                                          onPressed: () async {
                                            if (_homeC.wajah.value.isEmpty ||
                                                _homeC.wajah.value == '') {
                                              Get.dialog(
                                                  AlertDialog(
                                                    title: const Text(
                                                        'Peringatan'),
                                                    content: const Text(
                                                        'Anda Belum Melakukan Rekaman Wajah'),
                                                    actions: [
                                                      FlatButton(
                                                        child: const Text(
                                                            'Rekam Sekarang'),
                                                        onPressed: () {
                                                          Get.back();
                                                          Get.to(() =>
                                                              const ScanPage());
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  barrierDismissible: false);
                                            } else {
                                              (!_homeC.isAbsen.value)?
                                              Get.to(() =>
                                                  const FaceDetectorView()):
                                              Get.snackbar(
                                                  'Peringatan',
                                                  'Anda Sudah Absen',
                                                  icon: const Icon(
                                                    Icons.warning,
                                                    color: Colors.white,
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  colorText: Colors.white,
                                                 
                                                  snackPosition:
                                                      SnackPosition.TOP,
                                                  duration: const Duration(
                                                      seconds: 3)
                                              );
                                            }
                                          },
                                          child: const Text(
                                            'Absen',
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      )
                                    :
                                    // button
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        height: 50,
                                        child: RaisedButton(
                                          color: Colors.red,
                                          onPressed: () async {
                                            Get.snackbar(
                                              'Error',
                                              'Absensi Belum Dibuka/Sudah Ditutup',
                                              icon: const Icon(Icons.error),
                                              snackPosition: SnackPosition.TOP,
                                              backgroundColor: Colors.red,
                                            );
                                          },
                                          child: const Text(
                                            'Absen',
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Riwayat Absensi',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        for (int i = 0; i < _absenC.riwayatAbsen.length; i++)
                          Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 206, 206, 206),
                                      blurRadius: 9,
                                      blurStyle: BlurStyle.normal,
                                      spreadRadius: 0,
                                      offset: Offset(
                                        1,
                                        2,
                                      ),
                                    ),
                                  ]),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _absenC.riwayatAbsen[i]['tanggal'],
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        (_absenC.riwayatAbsen[i]['absen'] ==
                                                'H')
                                            ? 'Hadir'
                                            : 'Tidak Hadir',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 20),
                                  const CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.grey,
                                    ),
                                  ),
                                ],
                              ))
                      ],
                    ),
                  ),
                ),
              ),
            ),
            (isLoading.value)
                ? AnimatedContainer(
                    curve: Curves.easeInOut,
                    duration: const Duration(milliseconds: 1000),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.grey.withOpacity(0.8),
                    child: Center(
                      child: LoadingAnimationWidget.discreteCircle(
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  )
                : const SizedBox()
          ]),
        ),
      ),
    );
  }
}
