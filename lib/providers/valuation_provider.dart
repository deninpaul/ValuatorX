import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/models/valuation.dart';
import 'package:valuatorx/pages/common/status_icon.dart';
import 'package:valuatorx/providers/auth_provider.dart';
import 'package:valuatorx/services/draft_service.dart';
import 'package:valuatorx/services/onedrive_service.dart';
import 'package:valuatorx/services/valuation_service.dart';
import 'package:valuatorx/utils/common.dart';

class ValuationProvider extends ChangeNotifier {
  List<Valuation> get allValutions => drafts.reversed.toList() + valuations.reversed.toList();
  List<Valuation> valuations = [];
  List<Valuation> drafts = [];
  bool isLoading = false;
  bool isCreating = false;
  bool isDeleting = false;
  String selectedItem = "";

  final ValuationService service = ValuationService();
  final OneDriveService driveService = OneDriveService();
  final DraftService draftService = DraftService(boxName: "valuations");

  getValuations(BuildContext context, {bool refresh = true}) async {
    try {
      if (refresh) setLoading(true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      final result = await service.getExcelTable(client: client);
      valuations = result.map((item) => Valuation.fromJson(item)).toList();
      debugPrint("Fetched ${valuations.length} Valuation record(s) from Excel successfully.");
      notifyListeners();
    } catch (e) {
      valuations = [];
      debugPrint("Failed to fetch Valuations: ${e.toString()}");
    } finally {
      setLoading(false);
    }
  }

  Valuation getSelectedValuation() {
    return allValutions.firstWhere((report) => report.id == selectedItem);
  }

  List<Valuation> getSearchResults(String query) {
    return allValutions
        .where(
          (val) => "${val.reportName} ${val.status} ${val.dateOfInspection} ${val.bankDetails}".toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  addValuations(BuildContext context, Valuation newValuation) async {
    var success = false;
    try {
      setCreating(true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      await service.addToExcelTable(client: client, values: newValuation.toList());
      debugPrint("New Valuation added to Excel table successfully.");
      await getValuations(context, refresh: false);
      success = true;
    } catch (e) {
      debugPrint("Failed to add Valuation: ${e.toString()}");
    } finally {
      setCreating(false);
    }
    return success;
  }

  Future<bool> updateValuation(BuildContext context, Valuation valuation) async {
    var success = false;
    try {
      setCreating(true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      await service.updateExcelTableRow(client: client, index: valuation.id, values: valuation.toList());
      debugPrint("Valuation ${valuation.reportName} updated in Excel table successfully.");
      getValuations(context, refresh: false);
      success = true;
    } catch (e) {
      debugPrint("Failed to update Valuation: ${e.toString()}");
    } finally {
      setCreating(false);
    }
    return success;
  }

  deleteValuation(BuildContext context, Valuation valuation) async {
    try {
      setDeleting(true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      await service.deleteExcelTableRow(client: client, index: valuation.id);
      debugPrint("Valuation ${valuation.reportName} deleted from Excel table successfully.");
      await getValuations(context, refresh: false);
    } catch (e) {
      debugPrint("Failed to delete Valuation: ${e.toString()}");
    } finally {
      setDeleting(false);
    }
  }

  String generateIndex() {
    final ids = valuations.map((e) => int.tryParse(e.id)).whereType<int>().toList()..sort();
    return (ids.isEmpty ? 0 : ids.last + 1).toString();
  }

  getDrafts() async {
    try {
      var result = await draftService.getAllDrafts();
      drafts = result.map(((item) => Valuation.fromJson(item))).toList();
      debugPrint("Fetched ${drafts.length} Valuation record(s) from drafts.");
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to fetch Valuations from drafts: ${e.toString()}");
    }
  }

  Future<Map<dynamic, dynamic>> getDraft(String id) async {
    try {
      final result = await draftService.get(id);
      debugPrint("Fetched $id from drafts.");
      return result;
    } catch (e) {
      debugPrint("Failed to fetch Valuation from draft: ${e.toString()}");
    }
    return {};
  }

  createOrUpdateDraft(Valuation valuation) async {
    try {
      await draftService.put(valuation.id, valuation.toJson());
      debugPrint("Saved draft ${valuation.id} to drafts.");
      getDrafts();
    } catch (e) {
      debugPrint("Failed to save as drafts: ${e.toString()}");
    }
  }

  deleteDraft(String id) async {
    try {
      await draftService.delete(id);
      debugPrint("Deleted draft $id from drafts.");
      getDrafts();
    } catch (e) {
      debugPrint("Failed to delete draft: ${e.toString()}");
    }
  }

  Future<bool> draftExists(Valuation valuation) async {
    try {
      if (valuation.id.contains("draft_")) {
        return false; // return false if draft
      }
      var result = await draftService.getDraft(valuation.id);
      return result.isNotEmpty;
    } catch (e) {
      debugPrint("Failed to check whether draft ${valuation.id} exists: ${e.toString()}");
    }
    return false;
  }

  Future<String> generateDraftIndex() async {
    try {
      var result = await draftService.generateDraftId();
      return "draft_$result";
    } catch (e) {
      debugPrint("Failed to generate draft id: ${e.toString()}");
    }
    return "draft_0";
  }

  generateReport(BuildContext context, Valuation valuation, void Function(String message, {Status newStatus}) onStatusUpdate) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();

      onStatusUpdate("Generating Excel file");
      final newFileId = await service.createNewReportWorksheet(
        client: client,
        fileName: "${valuation.id} - ${valuation.reportName} - Valuation Data.xlsx",
      );

      onStatusUpdate("Linking values");
      final workbookLink = await service.getWorkbookLink(client: client);

      int column = 1;
      final values =
          valuation.toList().map((val) {
            final columnLetter = getExcelColumn(column++);
            final row = int.parse(valuation.id) + 2;
            return ["=LET(VAL, '$workbookLink'!$columnLetter$row, IF(VAL = \"\", \"\", VAL))"];
          }).toList();

      await service.addValuesToRange(client: client, range: "B1:B${values.length}", values: values, id: newFileId, sheet: "Data");

      onStatusUpdate("Fetching report link");
      final String reportLink = await driveService.getWebLink(client: client, id: newFileId);
      if (reportLink.isNotEmpty) {
        valuation.reportLink = reportLink;
        await updateValuation(context, valuation);
      } else {
        throw Exception("Could not fetch/update report link");
      }

      onStatusUpdate("Done", newStatus: Status.success);
    } catch (e) {
      onStatusUpdate("Failed to generate report: ${e.toString()}", newStatus: Status.error);
      debugPrint("Failed to generate report: ${e.toString()}");
    }
  }

  void setSelectedItem(String value, {bool notify = true}) {
    selectedItem = value;
    if (notify) {
      notifyListeners();
    }
  }

  void setLoading(bool value, {bool notify = true}) {
    isLoading = value;
    if (notify) {
      notifyListeners();
    }
  }

  void setCreating(bool value, {bool notify = true}) {
    isCreating = value;
    if (notify) {
      notifyListeners();
    }
  }

  void setDeleting(bool value, {bool notify = true}) {
    isDeleting = value;
    if (notify) {
      notifyListeners();
    }
  }
}
