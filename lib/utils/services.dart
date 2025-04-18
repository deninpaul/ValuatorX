List<Map<String, dynamic>> parseTableToJson({
  required Map<String, dynamic> fieldsData,
  required Map<String, dynamic> rowsData,
}) {
  final fields = (fieldsData["values"] as List<List<String>>)[0];
  final rows = rowsData["value"] as List<Map<String, dynamic>>;

  final List<Map<String, dynamic>> json = [];

  for (var row in rows) {
    final item = <String, dynamic>{};
    final values = (row["values"] as List<List<dynamic>>)[0];
    for (var i = 0; i < fields.length; i++) {
      item[fields[i]] = values[i];
    }
    item['id'] = row["index"];
    json.add(item);
  }

  return json;
}
