import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/providers/media_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:valuatorx/utils/common.dart';

// Location data model
class LocationData {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.timestamp,
  });

  String get formattedCoordinates => 'Lat ${latitude.toStringAsFixed(6)} / Long ${longitude.toStringAsFixed(6)}';
  String get formattedAddress => '$address, $city, $state $postalCode, $country';
  String get formattedTime =>
      '${timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12}:${timestamp.minute.toString().padLeft(2, '0')} ${timestamp.hour >= 12 ? 'PM' : 'AM'}';
}

// Location Details Screen
class LocationDetailsScreen extends StatefulWidget {
  final File file;
  final Uint8List fileBytes;
  const LocationDetailsScreen({super.key, required this.file, required this.fileBytes});

  @override
  State<LocationDetailsScreen> createState() => _LocationDetailsScreenState();
}

class _LocationDetailsScreenState extends State<LocationDetailsScreen> {
  LocationData? locationData;
  bool isLoadingLocation = true;
  bool imprintLocationDetails = true;
  String? locationError;
  bool isProcessingImage = false;
  bool isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<Uint8List> _imprintLocationOnImage(Uint8List imageBytes, LocationData location) async {
    // Load the original image
    final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image originalImg = frameInfo.image;

    // Create a canvas to draw on
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    // Draw the original image
    canvas.drawImage(originalImg, Offset.zero, Paint());

    // Prepare the location text
    final double imageWidth = originalImg.width.toDouble();
    final double imageHeight = originalImg.height.toDouble();

    // Create the location info box
    final double boxHeight = imageHeight * 0.2;
    final double boxWidth = imageWidth;
    final double boxX = 0;
    final double boxY = imageHeight - boxHeight;

    // Draw semi-transparent background
    final Paint backgroundPaint =
        Paint()
          ..color = Colors.black45
          ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(boxX, boxY, boxWidth, boxHeight), backgroundPaint);

    // Prepare text styles
    final double fontSize1 = boxHeight * 0.14;
    final double fontSize2 = boxHeight * 0.11;

    // Create text painters
    final TextPainter cityPainter = TextPainter(
      text: TextSpan(
        text: '${location.city}, ${location.state}, ${location.country}',
        style: TextStyle(color: Colors.white, fontSize: fontSize1, fontWeight: FontWeight.w500),
      ),
      textDirection: TextDirection.ltr,
    );

    final TextPainter addressPainter = TextPainter(
      text: TextSpan(text: location.formattedAddress, style: TextStyle(color: Colors.white70, fontSize: fontSize2)),
      textDirection: TextDirection.ltr,
    );

    final TextPainter coordsPainter = TextPainter(
      text: TextSpan(text: location.formattedCoordinates, style: TextStyle(color: Colors.white70, fontSize: fontSize2)),
      textDirection: TextDirection.ltr,
    );

    final TextPainter timePainter = TextPainter(
      text: TextSpan(text: location.formattedTime, style: TextStyle(color: Colors.white70, fontSize: fontSize2)),
      textDirection: TextDirection.ltr,
    );

    // Layout the text
    cityPainter.layout(maxWidth: boxWidth * 0.85);
    addressPainter.layout(maxWidth: boxWidth * 0.85);
    coordsPainter.layout(maxWidth: boxWidth * 0.85);
    timePainter.layout(maxWidth: boxWidth * 0.85);

    // Draw the text
    final double textStartX = boxX + boxWidth * 0.05;
    double currentY = boxY + boxHeight * 0.15;

    cityPainter.paint(canvas, Offset(textStartX, currentY));
    currentY += cityPainter.height + boxHeight * 0.04;

    addressPainter.paint(canvas, Offset(textStartX, currentY));
    currentY += addressPainter.height + boxHeight * 0.04;

    coordsPainter.paint(canvas, Offset(textStartX, currentY));
    currentY += coordsPainter.height + boxHeight * 0.04;

    timePainter.paint(canvas, Offset(textStartX, currentY));

    // Convert to image
    final ui.Picture picture = recorder.endRecording();
    final ui.Image finalImage = await picture.toImage(originalImg.width, originalImg.height);

    // Convert to bytes
    final ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List finalBytes = byteData!.buffer.asUint8List();

    return finalBytes;
  }

  _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          locationError = 'Location services are disabled';
          isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            locationError = 'Location permission denied';
            isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          locationError = 'Location permissions are permanently denied';
          isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        setState(() {
          locationData = LocationData(
            latitude: position.latitude,
            longitude: position.longitude,
            address: '${placemark.street ?? ''}, ${placemark.subLocality ?? ''}',
            city: placemark.locality ?? '',
            state: placemark.administrativeArea ?? '',
            country: placemark.country ?? '',
            postalCode: placemark.postalCode ?? '',
            timestamp: DateTime.now(),
          );
          isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        locationError = 'Error getting location: $e';
        isLoadingLocation = false;
      });
    }
  }

  getName(File file) => file.path.split('/').last + (kIsWeb ? ".png" : "");

  saveImage() async {
    setState(() => isProcessingImage = imprintLocationDetails && locationData != null);
    try {
      final provider = Provider.of<MediaProvider>(context, listen: false);
      final bytes =
          (imprintLocationDetails && locationData != null)
              ? await _imprintLocationOnImage(widget.fileBytes, locationData!)
              : widget.fileBytes;
      setState(() => isUploadingImage = true);
      final imageId = await provider.uploadImage(context, bytes, getName(widget.file));
      Navigator.pop(context, imageId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        isProcessingImage = false;
        isUploadingImage = false;
      });
    }
  }

  toggleDetails(bool value) {
    setState(() => imprintLocationDetails = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(elevation: 0, title: Text("Edit image", style: textTheme.bodyLarge)),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: isDesktop(context) ? MediaQuery.of(context).size.width * 0.21 : 16),
        child: Column(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    Positioned.fill(child: Image.memory(widget.fileBytes, fit: BoxFit.cover)),
                    if (imprintLocationDetails && locationError == null)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.black45),
                          child:
                              (imprintLocationDetails && locationData != null)
                                  ? Column(
                                    spacing: 4,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${locationData!.city}, ${locationData!.state}, ${locationData!.country}',
                                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis, // Handle long text
                                      ),
                                      Text(
                                        locationData!.formattedAddress,
                                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                                        maxLines: 2, // Limit lines to prevent overflow
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(locationData!.formattedCoordinates, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                                      Text(locationData!.formattedTime, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                                    ],
                                  )
                                  : Row(
                                    spacing: 16,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2),
                                      ),
                                      Text("Loading location details...", style: TextStyle(color: colorScheme.onPrimary)),
                                    ],
                                  ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (locationError == null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    Expanded(child: Text('Enable location details', style: textTheme.bodyLarge)),
                    Switch(
                      value: imprintLocationDetails,
                      onChanged: locationData != null ? toggleDetails : null,
                      activeColor: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            if (locationError != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: colorScheme.errorContainer, border: Border.all(color: colorScheme.error)),
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(Icons.error, color: colorScheme.error, size: 20),
                    Expanded(child: Text(locationError!, style: TextStyle(color: colorScheme.onErrorContainer))),
                  ],
                ),
              ),
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: kIsWeb ? 20 : 16),
                      backgroundColor: colorScheme.surfaceContainerHigh,
                      foregroundColor: colorScheme.onSurface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: (isProcessingImage || locationData == null && locationError == null) ? null : saveImage,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: kIsWeb ? 20 : 16),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      disabledBackgroundColor: theme.disabledColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    ),
                    icon:
                        isProcessingImage
                            ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: theme.disabledColor, strokeWidth: 2))
                            : Icon(Icons.save_outlined),
                    label:
                        isProcessingImage
                            ? (Text(isUploadingImage ? "Uploading" : "Processing", style: TextStyle(color: theme.disabledColor)))
                            : Text(imprintLocationDetails && locationData != null ? ' Save with Location' : 'Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
