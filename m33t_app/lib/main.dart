import 'package:flutter/material.dart';
import 'location_service.dart';
import 'package:geolocator/geolocator.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'm33t',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LocationTracker(),
    );
  }
}

class LocationTracker extends StatefulWidget {
  @override
  _LocationTrackerState createState() => _LocationTrackerState();
}

class _LocationTrackerState extends State<LocationTracker> {
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _locationService.startTracking();
  }

  @override
  void dispose() {
    _locationService.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Tracker'),
      ),
      body: StreamBuilder<Position>(
        stream: _locationService.positionStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final position = snapshot.data!;
            return Center(
              child: Text(
                'Lat: ${position.latitude}, Lng: ${position.longitude}',
                style: TextStyle(fontSize: 24),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
