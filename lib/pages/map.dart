import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyLocation extends StatefulWidget {
  const MyLocation({Key? key,required this.username,required this.users}) : super(key: key);
  final List users;
  final String username;
  @override
  _MyLocationState createState() => _MyLocationState();
}

class _MyLocationState extends State<MyLocation> with SingleTickerProviderStateMixin {
  late LocationData _currentPosition;
  bool _currentPositionbool = false;
  late GoogleMapController mapController;
  late Marker marker;
  Location location = Location();
  late GoogleMapController _controller;
  LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
  bool _swipe = false;
  bool _showonappear = false;
  bool _myLocenabled = true;
  bool _isloading = true;

  @override
  void initState() {
    super.initState();
    getLoc().whenComplete(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _controller;
    if (_myLocenabled == true) {
      location.onLocationChanged.listen((l) {
        _controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(l.latitude!, l.longitude!), zoom: 15),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: _isloading
            ? Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Center(child: CircularProgressIndicator()))
            : Scaffold(
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              initialCameraPosition:
              CameraPosition(target: _initialcameraposition, zoom: 3),
              mapType: MapType.normal,
              onMapCreated: _onMapCreated,
              myLocationEnabled: _myLocenabled,
            ),
          ),
        ));
  }

  getLoc() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        setState(() {
          _myLocenabled = false;
        });
        setState(() {
          _isloading = false;
        });

        return;
      }
      else{
        setState(() {
          _isloading = false;
        });
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        setState(() {
          _myLocenabled = false;
        });
        setState(() {
          _isloading = false;
        });

        return;
      }
      else{
        setState(() {
          _isloading = false;
        });
      }
    }

    _currentPosition = await location.getLocation();
    setState(() {
      _currentPositionbool = true;
    });
    _initialcameraposition =
        LatLng(_currentPosition.latitude!, _currentPosition.longitude!);
    setState(() {
      _isloading = false;
    });
    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentPosition = currentLocation;
        _initialcameraposition =
            LatLng(_currentPosition.latitude!, _currentPosition.longitude!);
      });
    });
  }


}
