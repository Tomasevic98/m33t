import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart'; 

class LocationService {
  StreamController<Position> _positionController = StreamController<Position>();
  final String apiUrl = 'http://192.168.178.25:8000/api/location/'; // Tvoj server URL

  Stream<Position> get positionStream => _positionController.stream;

  void startTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Dozvola za lokaciju je odbijena.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Dozvola za lokaciju je trajno odbijena.');
      return;
    }

    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, 
      ),
    ).listen((Position position) {
      if (position != null) {
        _positionController.add(position);
        _sendLocationToServer(position);
      }
    });
  }

  void stopTracking() {
    _positionController.close();
  }

  Future<void> _sendLocationToServer(Position position) async {
    final userId = '1'; // Postavi ID korisnika

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );

      if (response.statusCode == 200) {
        print('Lokacija uspešno poslata na server: ${response.body}');
      } else {
        print('Greška prilikom slanja lokacije: ${response.body}');
      }
    } catch (e) {
      print('Greška: $e');
    }
  }
}
