import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool chDone = false;
  GoogleMapController? mapController;

  // latitude , longitude
  static final LatLng cmpLatLng = LatLng(
    35.8181573,
    127.1077327,
  );

  static final double distance = 100;

  static final Circle circle1 = Circle(
    circleId: CircleId('circle'),
    center: cmpLatLng,
    fillColor: Colors.blue.withOpacity(0.5),
    radius: distance,
    strokeColor: Colors.blue,
    strokeWidth: 1,
  );

  static final Circle circle2 = Circle(
    circleId: CircleId('circle2'),
    center: cmpLatLng,
    fillColor: Colors.red.withOpacity(0.5),
    radius: distance,
    strokeColor: Colors.red,
    strokeWidth: 1,
  );

  static final Circle circle3 = Circle(
    circleId: CircleId('circle3'),
    center: cmpLatLng,
    fillColor: Colors.green.withOpacity(0.5),
    radius: distance,
    strokeColor: Colors.green,
    strokeWidth: 1,
  );

  final Marker marker = Marker(
    markerId: MarkerId('marker'),
    position: cmpLatLng,
  );

  static final CameraPosition cmeraPosition = CameraPosition(
    target: cmpLatLng,
    zoom: 15,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: rendeApprBar(),
      body: FutureBuilder(
        future: checkPermission(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == '위치 권한이 허가 되었습니다.') {
            return StreamBuilder<Position>(
                stream: Geolocator.getPositionStream(),
                builder: (context, snapshot) {
                  bool rangTf = false;

                  if (snapshot.hasData) {
                    final start = snapshot.data!;
                    final end = cmpLatLng;
                    final check = Geolocator.distanceBetween(
                      start.latitude,
                      start.longitude,
                      end.latitude,
                      end.longitude,
                    );

                    if (check < distance) {
                      rangTf = true;
                    }
                  }

                  return Column(
                    children: [
                      _CustomGoogleMap(
                        cmeraPosition: cmeraPosition,
                        circle: chDone
                            ? circle3
                            : rangTf
                                ? circle1
                                : circle2,
                        marker: marker,
                        onMapCreate: onMapCreate,
                      ),
                      _CumBtn(
                        rangTf: rangTf,
                        chDone: chDone,
                        onPressed: onCumPressed,
                      ),
                    ],
                  );
                });
          }

          return Center(
            child: Text(snapshot.data),
          );
        },
      ),
    );
  }

  onCumPressed() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('출근하기'),
          content: Text('출근을 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('출근하기'),
            ),
          ],
        );
      },
    );

    if (result) {
      setState(() {
        chDone = true;
      });
    }
  }

  onMapCreate(GoogleMapController controller) {
    mapController = controller;
  }

  AppBar rendeApprBar() {
    return AppBar(
      title: Text(
        'WORK',
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: () async {
            if (mapController == null) {
              return;
            }

            final location = await Geolocator.getCurrentPosition();

            mapController!.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(location.latitude, location.longitude),
              ),
            );
          },
          icon: Icon(
            Icons.my_location,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}

class _CustomGoogleMap extends StatelessWidget {
  final CameraPosition cmeraPosition;
  final Circle circle;
  final Marker marker;
  final MapCreatedCallback? onMapCreate;

  const _CustomGoogleMap({
    required this.cmeraPosition,
    required this.circle,
    required this.marker,
    required this.onMapCreate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: cmeraPosition,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        circles: Set.from([circle]),
        markers: Set.from([marker]),
        onMapCreated: onMapCreate,
      ),
    );
  }
}

Future<String> checkPermission() async {
  final isEnabled = await Geolocator.isLocationServiceEnabled();

  if (!isEnabled) {
    return '위치 서비스를 활성화 해주세요.';
  }

  LocationPermission checkPermisson = await Geolocator.checkPermission();

  if (checkPermisson == LocationPermission.denied) {
    checkPermisson = await Geolocator.requestPermission();

    if (checkPermisson == LocationPermission.denied) {
      return '위치 권한을 허가해주세요.';
    }
  }

  if (checkPermisson == LocationPermission.deniedForever) {
    return '앱의 위치 권한을 세팅해서 허가해주세요.';
  }

  return '위치 권한이 허가 되었습니다.';
}

class _CumBtn extends StatelessWidget {
  final rangTf;
  final chDone;
  final VoidCallback onPressed;

  const _CumBtn({
    required this.rangTf,
    required this.onPressed,
    required this.chDone,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timelapse_outlined,
            size: 50.0,
            color: chDone
                ? Colors.green
                : rangTf
                    ? Colors.blue
                    : Colors.red,
          ),
          const SizedBox(
            height: 20.0,
          ),
          if (rangTf && !chDone)
            TextButton(
              onPressed: onPressed,
              child: Text('출근하기'),
            ),
        ],
      ),
    );
  }
}
