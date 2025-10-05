import 'package:oauth2/oauth2.dart';
import 'package:valuatorx/models/land_rate.dart';
import 'package:valuatorx/services/excel_service.dart';

class LandRateService extends ExcelService {
  final String tableName;

  LandRateService({required this.tableName})
    : super(fileId: "01OTD6NSN7IGJ5FI3I6VHZYRYP2NPR5CQZ", userId: "a328ee73-9709-4f7c-bb40-ae497e488a66", tableName: tableName);

  @override
  Future<List<Map<String, dynamic>>> getExcelTable({required Client client}) async {
    final result = await super.getExcelTable(client: client);
    return result
        .where((entry) => "${entry[LandRate.SL_NO]}".trim().isNotEmpty)
        .map(((entry) => {...entry, LandRate.AUTHOR: tableName}))
        .toList();
  }
}
