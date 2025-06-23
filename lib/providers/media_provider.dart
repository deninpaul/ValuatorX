import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/providers/auth_provider.dart';
import 'package:valuatorx/services/onedrive_service.dart';

class MediaProvider extends ChangeNotifier {
  final OneDriveService driveService = OneDriveService();

  Future<String> uploadImage(BuildContext context, File image) async {
    String id = "";
    final fileData = await image.readAsBytes();
    final fileName = image.path.split('/').last;
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      id = await driveService.uploadFile(client: client, name: fileName, file: fileData);
    } catch (e) {
      debugPrint("Failed to upload image: ${e.toString()}");
    }
    return id;
  }

  Future<List<String>> getImages(BuildContext context, List<String> ids) async {
    List<String> downloadLinks = [];
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      for (var id in ids) {
        final String downloadLink = await driveService.getFileDownloadLink(client: client, id: id);
        downloadLinks.add(downloadLink);
      }
      return downloadLinks;
    } catch (e) {
      debugPrint("Failed to download image: ${e.toString()}");
    }
    return downloadLinks;
  }

  Future<String> openImageUrl(BuildContext context, String id) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      return await driveService.getWebLink(client: client, id: id);
    } catch (e) {
      debugPrint("Failed to get URL for image: ${e.toString()}");
    }
    return "";
  }
}
