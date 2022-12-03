import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as lct;
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  late lct.Location location;
  double latitude = 0.0;
  double longitude = 0.0;

  @override
  void initState() {
    requestPerms();
    super.initState();
  }

  getLocation() async {
    var currentLocation = await location.getLocation();
    locationUpdate(currentLocation);
  }

  locationUpdate(currentLocation) async {
    if (currentLocation != null) {
      if (mounted) {
        setState(() {
          latitude = currentLocation.latitude;
          longitude = currentLocation.longitude;
        });
      }
    }
  }

  changedLocation() {
    location.onLocationChanged.listen((lct.LocationData cLoc) {
      if (cLoc != null) locationUpdate(cLoc);
    });
  }

  requestPerms() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.locationAlways].request();
    var status = statuses[Permission.locationAlways];
    if (status == PermissionStatus.denied) {
      requestPerms();
    } else {
      gpsAnable();
    }
  }

  gpsAnable() async {
    location = lct.Location();
    bool statusResult = await location.requestService();
    if (!statusResult) {
      gpsAnable();
    } else {
      getLocation();
      changedLocation();
    }
  }

  Future<void> sendlocation(double lat, double lng) async {
    var url1 =
        "https://back-end-blackout-production.up.railway.app/add/location";
    final Uri url = Uri.parse(url1);
    await http.post(
      url,
      headers: <String, String>{'Content-Type': 'application/json'},
      body: json.encode(
        {
          'latitude': lat,
          'longitude': lng,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lat: $latitude'),
            const SizedBox(height: 6.0),
            Text('Lng: $longitude'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => sendlocation(latitude, longitude),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text("Send Location"),
            )
          ],
        ),
      ),
    );
  }
}
