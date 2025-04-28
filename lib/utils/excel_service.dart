import 'dart:convert';
import 'package:oauth2/oauth2.dart';

class LandRateService extends _ExcelService {
  LandRateService() : super(fileId: "01OTD6NSLEWCWDOWM7WBAYNYM5RMPDACQR", tableName: "LandRate");
}

class ValuationService extends _ExcelService {
  ValuationService() : super(fileId: "01OTD6NSIJ4LY4ONM7ZVD3B2CK4MAL5TLC", tableName: "ValuationReport");
}

class _ExcelService {
  late final String tableRowsEndpoint;
  late final String tableHeadersEndpoint;
  late final String addTableEndpoint;
  late final String tableRowEndpoint;

  _ExcelService({fileId, tableName}) {
    tableRowsEndpoint = "https://graph.microsoft.com/v1.0/me/drive/items/$fileId/workbook/tables/$tableName/rows";
    tableHeadersEndpoint = "https://graph.microsoft.com/v1.0/me/drive/items/$fileId/workbook/tables/$tableName/headerRowRange";
    addTableEndpoint = "https://graph.microsoft.com/v1.0/me/drive/items/$fileId/workbook/tables/$tableName/rows/add";
    tableRowEndpoint = "https://graph.microsoft.com/v1.0/me/drive/items/$fileId/workbook/tables/$tableName/rows/\$/ItemAt(index=_ID_)";
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

  updateExcelTableRow({required Client client, required int index, required List values}) async {
    try {
      final response = await client.patch(
        Uri.parse(tableRowEndpoint.replaceAll("_ID_", index.toString())),
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

  deleteExcelTableRow({required Client client, required int index}) async {
    try {
      final response = await client.delete(Uri.parse(tableRowEndpoint.replaceAll("_ID_", index.toString())));
      if (response.statusCode != 204) {
        throw Exception("Error deleting Excel Table row. ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      throw Exception("Error deleting Excel table row: $e");
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
