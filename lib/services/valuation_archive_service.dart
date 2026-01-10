import 'package:valuatorx/services/excel_service.dart';

class ValuationArchiveService extends ExcelService {
  ValuationArchiveService()
    : super(
        fileId: "01OTD6NSMZJ7N4IWTSDVDI3XVCUYQPC4TM",
        userId: "a328ee73-9709-4f7c-bb40-ae497e488a66",
        tableName: "Valuations",
        sheetName: "Data",
      );
}
