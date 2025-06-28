import 'dart:convert';
import 'package:oauth2/oauth2.dart';

class ExcelService {
  late final String tableRowsEndpoint;
  late final String tableHeadersEndpoint;
  late final String addTableEndpoint;
  late final String tableRowEndpoint;
  late final String fileUploadEndpoint;
  late final String fileEndpoint;
  late final String fileId;
  late final String sheetName;
  late final String userId;

  ExcelService({required this.fileId, tableName, this.sheetName = "Sheet1", this.userId = "me"}) {
    tableRowsEndpoint = "https://graph.microsoft.com/v1.0/users/$userId/drive/items/$fileId/workbook/tables/$tableName/rows";
    tableHeadersEndpoint = "https://graph.microsoft.com/v1.0/users/$userId/drive/items/$fileId/workbook/tables/$tableName/headerRowRange";
    addTableEndpoint = "https://graph.microsoft.com/v1.0/users/$userId/drive/items/$fileId/workbook/tables/$tableName/rows/add";
    tableRowEndpoint = "https://graph.microsoft.com/v1.0/users/$userId/drive/items/$fileId/workbook/tables/$tableName/rows/\$/ItemAt(index=_ID_)";
    fileUploadEndpoint = "https://graph.microsoft.com/v1.0/users/$userId/drive/root:/SAMANTO ASSOCIATES (P) Ltd/00 VALUATION/Apps/Uploads/_NAME_:/content";
    fileEndpoint = "https://graph.microsoft.com/v1.0/users/$userId/drive/items/_ID_";
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

  Future<List> generateTableValues({required Client client, required Map<String, dynamic> data}) async {
    var response = await client.get(Uri.parse(tableHeadersEndpoint));
    if (response.statusCode != 200) {
      throw Exception("Error fetching table headers. ${response.statusCode} ${response.body}");
    }
    final headerData = jsonDecode(response.body);

    final headers = headerData["values"][0] as List;
    final List<String> tableValue = [];
    for (var header in headers) {
      tableValue.add(data[header] ?? "");
    }
    return tableValue;
  }

  getWorkbookLink({required Client client}) async {
    try {
      final response = await client.get(Uri.parse(fileEndpoint.replaceAll("_ID_", fileId)));
      if (response.statusCode != 200) {
        throw Exception("Error generating workbook link. ${response.statusCode} ${response.body}");
      }
      final details = json.decode(response.body);
      final oneDriveRoot = (details["webUrl"] as String).split("/_layouts")[0];
      final path = (details["parentReference"]["path"] as String).split("root:/")[1];
      final fileName = (details["name"] as String);
      return [oneDriveRoot, "Documents", path, "[$fileName]$sheetName"].join('/');
    } catch (e) {
      throw Exception("Error generating workbook link. $e");
    }
  }

  addValuesToRange({required Client client, required List<List<String>> values, required String range, String? id, String? sheet}) async {
    id = id ?? fileId;
    sheet = sheet ?? sheetName;
    try {
      final response = await client.patch(
        Uri.parse("${fileEndpoint.replaceAll("_ID_", id)}/workbook/worksheets/$sheet/range(address='$range')"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"values": values}),
      );
      if (response.statusCode != 200) {
        throw Exception("Error adding values to specifiec range. ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      throw Exception("Error adding values to specifiec range. $e");
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
