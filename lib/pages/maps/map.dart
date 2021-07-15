import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/services.dart' show rootBundle;

class MyLocation extends StatefulWidget {
  const MyLocation(
      {Key? key,
      required this.username,
      required this.userid,
      required this.users,
      required this.grpid,
      required this.userlat,
      required this.userlong,
      required this.isDark})
      : super(key: key);
  final List users;
  final String username;
  final String grpid;
  final String userid;
  final double userlat;
  final double userlong;
  final bool isDark;

  @override
  _MyLocationState createState() => _MyLocationState();
}

class _MyLocationState extends State<MyLocation> {
  late GoogleMapController mapController;
  late Marker marker;
  Location location = Location();
  late GoogleMapController _controller;
  late LatLng _initialcameraposition;
  BehaviorSubject<double> radius = BehaviorSubject();
  late Stream<List<DocumentSnapshot>> stream;
  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('groups');
  List<Marker> markers = [];
  late String _mapStyle;

  @override
  void initState() {
    super.initState();
    if (widget.isDark) {
      rootBundle.loadString('assets/styles_json/dark.json').then((string) {
        _mapStyle = string;
      });
    } else {
      rootBundle.loadString('assets/styles_json/light.json').then((string) {
        _mapStyle = string;
      });
    }
    _initialcameraposition = LatLng(widget.userlat, widget.userlong);
    GeoFirePoint center = Geoflutterfire()
        .point(latitude: widget.userlat, longitude: widget.userlong);
    stream = radius.switchMap((rad) {
      return Geoflutterfire()
          .collection(
              collectionRef:
                  collectionReference.doc(widget.grpid).collection('locations'))
          .within(
              center: center, radius: rad, field: 'position', strictMode: true);
    });
  }

  @override
  void dispose() {
    setState(() {
      _controller.dispose();
    });
    super.dispose();
  }

  void _onMapCreated(GoogleMapController _controller) {
    _controller = _controller;
    _controller.setMapStyle(_mapStyle);

    location.onLocationChanged.listen((l) {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude!, l.longitude!), zoom: 17),
        ),
      );
      print(l.latitude);
      GeoFirePoint myloc = Geoflutterfire()
          .point(latitude: l.latitude!, longitude: l.longitude!);
      dbadd(myloc);
    });
    stream.listen((List<DocumentSnapshot> documentList) {
      _updateMarkers(documentList);
    });
  }

  dbadd(GeoFirePoint myloc) {
    collectionReference
        .doc(widget.grpid)
        .collection('locations')
        .doc(widget.userid)
        .set({'name': widget.username, 'position': myloc.data});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Track Location"),
        centerTitle: true,
        // backgroundColor:
        //     !isSwitcheddark ? ThemeData().accentColor : Color(0xff6d6666)),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: _initialcameraposition, zoom: 3),
              mapType: MapType.normal,
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              markers: markers.toSet(),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 10,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Slider(
                min: 0,
                max: 1000,
                divisions: 1000,
                value: _value,
                label: _label,
                activeColor: Colors.blue,
                inactiveColor: Colors.blue.withOpacity(0.2),
                onChanged: (double value) => changed(value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addMarker(double lat, double lng, String name) {
    var _marker = Marker(
        markerId: MarkerId(UniqueKey().toString()),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: InfoWindow(title: name, snippet: '${lat},${lng}'));
    setState(() {
      markers.add(_marker);
    });
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    markers.clear();
    documentList.forEach(
      (DocumentSnapshot document) {
        GeoPoint point = document['position']['geopoint'];
        String name = document['name'];
        _addMarker(point.latitude, point.longitude, name);
      },
    );
  }

  double _value = 0.0;
  String _label = ' Adjust Radius';

  changed(value) {
    setState(
      () {
        _value = value;
        _label = '${_value.toInt().toString()} kms';
        markers.clear();
        radius.add(value);
      },
    );
  }
}
