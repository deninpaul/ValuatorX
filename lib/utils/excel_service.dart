import 'dart:convert';
import 'dart:typed_data';
import 'package:oauth2/oauth2.dart';

class LandRateService extends _ExcelService {
  LandRateService() : super(fileId: "01OTD6NSLEWCWDOWM7WBAYNYM5RMPDACQR", tableName: "LandRate");
}

class ValuationService extends _ExcelService {
  ValuationService() : super(fileId: "01OTD6NSIJ4LY4ONM7ZVD3B2CK4MAL5TLC", tableName: "Valuations");
}

class _ExcelService {
  late final String tableRowsEndpoint;
  late final String tableHeadersEndpoint;
  late final String addTableEndpoint;
  late final String tableRowEndpoint;
  late final String fileUploadEndpoint;
  late final String fileDownloadEndpoint;

  _ExcelService({fileId, tableName}) {
    tableRowsEndpoint = "https://graph.microsoft.com/v1.0/me/drive/items/$fileId/workbook/tables/$tableName/rows";
    tableHeadersEndpoint = "https://graph.microsoft.com/v1.0/me/drive/items/$fileId/workbook/tables/$tableName/headerRowRange";
    addTableEndpoint = "https://graph.microsoft.com/v1.0/me/drive/items/$fileId/workbook/tables/$tableName/rows/add";
    tableRowEndpoint = "https://graph.microsoft.com/v1.0/me/drive/items/$fileId/workbook/tables/$tableName/rows/\$/ItemAt(index=_ID_)";
    fileUploadEndpoint = "https://graph.microsoft.com/v1.0/me/drive/root:/Documents/Test/Images/_NAME_:/content";
    fileDownloadEndpoint = "https://graph.microsoft.com/v1.0/me/drive/items/_ID_";
  }

  Future<List<Map<String, dynamic>>> getExcelTable({required Client client}) async {
    try {
      // Get field names from excel table
      dynamic fieldResponseBody = {};
      var response = await client.get(Uri.parse(tableHeadersEndpoint));
      if (response.statusCode == 200) {
        fieldResponseBody = jsonDecode(response.body);
      }

      // Get values/rows from excel table
      dynamic rowResponseBody = {};
      response = await client.get(Uri.parse(tableRowsEndpoint));
      if (response.statusCode == 200) {
        rowResponseBody = jsonDecode(response.body);
      }
      return _parseTableToJson(fieldsData: fieldResponseBody, rowsData: rowResponseBody);
    } catch (e) {
      throw Exception("Error fetching Excel table: $e");
    }
  }

  addToExcelTable({required Client client, required List values}) async {
    try {
      final response = await client.post(
        Uri.parse(addTableEndpoint),
        body: jsonEncode({
          "values": [values],
        }),
      );
      if (response.statusCode != 201) {
        throw Exception("Error adding to Excel Table. ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      throw Exception("Error adding to Excel table: $e");
    }
  }

  updateExcelTableRow({required Client client, required String index, required List values}) async {
    try {
      final response = await client.patch(
        Uri.parse(tableRowEndpoint.replaceAll("_ID_", index)),
        body: jsonEncode({
          "values": [values],
        }),
      );
      if (response.statusCode != 200) {
        throw Exception("Error updating Excel Table row. ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      throw Exception("Error updating Excel table row: $e");
    }
  }

  deleteExcelTableRow({required Client client, required String index}) async {
    try {
      final response = await client.delete(Uri.parse(tableRowEndpoint.replaceAll("_ID_", index)));
      if (response.statusCode != 204) {
        throw Exception("Error deleting Excel Table row. ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      throw Exception("Error deleting Excel table row: $e");
    }
  }

  uploadFile({required Client client, required String name, required Uint8List file, contentType = "image/jpeg"}) async {
    try {
      final response = await client.put(
        Uri.parse(fileUploadEndpoint.replaceAll("_NAME_", name)),
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

  getFileDownloadLink({required Client client, required String id}) async {
    try {
      final response = await client.get(Uri.parse(fileDownloadEndpoint.replaceAll("_ID_", id)));
      if (response.statusCode != 200) {
        throw Exception("Error retrieving download file link $id. ${response.statusCode} ${response.body}");
      }
      final responseData = json.decode(response.body);
      return responseData['@microsoft.graph.downloadUrl'] as String;
    } catch (e) {
      throw Exception("Error retrieving download file link $id: $e");
    }
  }

  List<Map<String, dynamic>> _parseTableToJson({required Map<String, dynamic> fieldsData, required Map<String, dynamic> rowsData}) {
    final fields = fieldsData["values"][0];
    final rows = rowsData["value"];

    final List<Map<String, dynamic>> json = [];

    for (var row in rows) {
      final item = <String, dynamic>{};
      final values = row["values"][0] as List;
      if (values.isNotEmpty) {
        for (var i = 0; i < fields.length; i++) {
          item[fields[i]] = values[i];
        }
        item['id'] = row["index"].toString();
        json.add(item);
      }
    }

    return json;
  }
}
