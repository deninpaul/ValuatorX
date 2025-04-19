import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

Future<LatLng?> getCurrentPosition() async {
  final permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
    throw Exception("Location access denied");
  }
  final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  return LatLng(position.latitude, position.longitude);
}
