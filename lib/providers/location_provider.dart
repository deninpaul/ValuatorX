import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {
  bool isLoading = false;
  LatLng currentLocation = LatLng(0, 0);

  moveToMyLocation(MapController controller) async {
    try {
      setLoading(true);
      currentLocation = await getCurrentPosition();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.move(currentLocation, 15.2);
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<LatLng> getCurrentPosition() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      throw Exception("Location access denied");
    }
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return LatLng(position.latitude, position.longitude);
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
