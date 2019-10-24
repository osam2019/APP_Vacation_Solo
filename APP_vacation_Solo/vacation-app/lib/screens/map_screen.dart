import 'package:flash_chat/screens/user_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreenState extends StatelessWidget {
  final double lat;
  final double lng;
  Set<Marker> _Marker;
  GoogleMapController mapController;
  MapScreenState({Key key, @required this.lat, @required this.lng})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                  _Marker.add(Marker(
                    position: LatLng(lat, lng),
                    markerId: MarkerId(""),
                  ));
                },
                markers: _Marker,
                initialCameraPosition: CameraPosition(
                    target: _Marker.isEmpty == null
                        ? LatLng(37.532600, 127.024612)
                        : _Marker.first.position),
              ),
            ),
          ],
        ));
  }
}
