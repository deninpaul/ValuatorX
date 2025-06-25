import 'dart:convert';
import 'dart:typed_data';
import 'package:oauth2/oauth2.dart';

class OneDriveService {
  late final String uploadEndpoint;
  late final String fileEndpoint;
  late final String userId;

  OneDriveService() {
    userId = "a328ee73-9709-4f7c-bb40-ae497e488a66";
    uploadEndpoint = "https://graph.microsoft.com/v1.0/users/$userId/drive/root:/SAMANTO ASSOCIATES (P) Ltd/00 VALUATION/Apps/Uploads/_NAME_:/content";
    fileEndpoint = "https://graph.microsoft.com/v1.0/users/$userId/drive/items/_ID_";
  }

  uploadFile({required Client client, required String name, required Uint8List file, contentType = "image/jpeg"}) async {
    try {
      final response = await client.put(
        Uri.parse(uploadEndpoint.replaceAll("_NAME_", name)),
        headers: {"Content-Type": contentType},
        body: file,
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Error uploading file $name. ${response.statusCode} ${response.body}");
      }
      final responseData = json.decode(response.body);
      return responseData['id'] as String;
    } catch (e) {
      throw Exception("Error uploading file $name: $e");
    }
  }

  Future<String> getWebLink({required Client client, required String id}) async {
    try {
      final response = await client.get(Uri.parse(fileEndpoint.replaceAll("_ID_", id)));
      if (response.statusCode != 200) {
        throw Exception("Error getting web link. ${response.statusCode} ${response.body}");
      }
      final responseData = json.decode(response.body);
      return responseData["webUrl"] as String;
    } catch (e) {
      throw Exception("Error getting web link. $e");
    }
  }

  getFileDownloadLink({required Client client, required String id}) async {
    try {
      final response = await client.get(Uri.parse(fileEndpoint.replaceAll("_ID_", id)));
      if (response.statusCode != 200) {
        throw Exception("Error retrieving download file link $id. ${response.statusCode} ${response.body}");
      }
      final responseData = json.decode(response.body);
      return responseData['@microsoft.graph.downloadUrl'] as String;
    } catch (e) {
      throw Exception("Error retrieving download file link $id: $e");
    }
  }
}
