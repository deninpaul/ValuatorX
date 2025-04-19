import 'dart:convert';
import 'package:oauth2/oauth2.dart';

class LandRateService extends _ExcelService {
  LandRateService() : super(fileId: "01OTD6NSLEWCWDOWM7WBAYNYM5RMPDACQR", tableName: "LandRate");
}

class _ExcelService {
  late final String getTableEndpoint;
  late final String addTableEndpoint;

  _ExcelService({fileId, tableName}) {
    getTableEndpoint = "https://graph.microsoft.com/v1.0/me/drive/items/$fileId/workbook/tables/$tableName";
    addTableEndpoint = "https://graph.microsoft.com/v1.0/me/drive/items/$fileId/workbook/tables/$tableName/rows/add";
  }

  Future<List<Map<String, dynamic>>> getExcelTable({required Client client}) async {
    try {
      // Get field names from excel table
      dynamic fieldResponseBody = {};
      var response = await client.get(Uri.parse("$getTableEndpoint/headerRowRange"));
      if (response.statusCode == 200) {
        fieldResponseBody = jsonDecode(response.body);
      }

      // Get values/rows from excel table
      dynamic rowResponseBody = {};
      response = await client.get(Uri.parse("$getTableEndpoint/rows"));
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
        throw Exception("Error adding to Excel Table. ${response.statusCode} ${response.toString()}");
      }
    } catch (e) {
      throw Exception("Error adding to Excel table: $e");
    }
  }

  List<Map<String, dynamic>> _parseTableToJson({
    required Map<String, dynamic> fieldsData,
    required Map<String, dynamic> rowsData,
  }) {
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
        item['id'] = row["index"];
        json.add(item);
      }
    }

    return json;
  }
}
