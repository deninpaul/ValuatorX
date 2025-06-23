import 'dart:convert';
import 'package:oauth2/oauth2.dart';
import 'package:valuatorx/services/excel_service.dart';

class ValuationService extends ExcelService {
  ValuationService() : super(fileId: "01OTD6NSIJ4LY4ONM7ZVD3B2CK4MAL5TLC", tableName: "Valuations", sheetName: "Data");

  final _driveId = "b!bjWHx8vaSUGa2c_fZH7AoTlNAe4QjSFKrgLAyq8Smcgfz6YLhZb1T7j74-c_w8yy";
  final _reportPath = "/drive/root:/SAMANTO ASSOCIATES (P) Ltd/00 VALUATION/Apps/Uploads";
  final _templateId = "01OTD6NSJ2IQ6WYOP24BA2W4XBSB2EYCDD";

  createNewReportWorksheet({required Client client, required String fileName}) async {
    try {
      // Create new file based of template
      final response = await client.post(
        Uri.parse("${fileEndpoint.replaceAll("_ID_", _templateId)}/copy"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "parentReference": {"driveId": _driveId, "path": _reportPath},
          "name": fileName,
        }),
      );
      if (response.statusCode != 202 && response.statusCode != 409) {
        throw Exception("Error creating new report workbook. ${response.statusCode} ${response.body}");
      }
      // Get file ID of new file
      final fileResponse = await client.get(Uri.parse("https://graph.microsoft.com/v1.0/me$_reportPath/$fileName"));
      if (fileResponse.statusCode != 200) {
        throw Exception("Error retrieving file id. ${fileResponse.statusCode} ${fileResponse.body}");
      }
      final fileResponseData = json.decode(fileResponse.body);
      return fileResponseData["id"];
    } catch (e) {
      throw Exception("Error creating new report workbook: $e");
    }
  }
}
