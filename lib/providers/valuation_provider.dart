import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/models/valuation.dart';
import 'package:valuatorx/pages/common/status_icon.dart';
import 'package:valuatorx/providers/auth_provider.dart';
import 'package:valuatorx/services/draft_service.dart';
import 'package:valuatorx/services/onedrive_service.dart';
import 'package:valuatorx/services/valuation_archive_service.dart';
import 'package:valuatorx/services/valuation_service.dart';
import 'package:valuatorx/utils/common.dart';

class ValuationProvider extends ChangeNotifier {
  List<Valuation> valuations = [];
  List<Valuation> drafts = [];
  List<Valuation> archived = [];
  bool isLoading = false;
  bool isCreating = false;
  bool isDeleting = false;
  String selectedItem = "";

  List<Valuation> get allValutions => drafts.reversed.toList() + valuations.reversed.toList();
  List<Valuation> get templates => valuations.where((val) => val.status == 'Template').toList();

  final ValuationService service = ValuationService();
  final ValuationArchiveService archiveService = ValuationArchiveService();
  final OneDriveService driveService = OneDriveService();
  final DraftService draftService = DraftService(boxName: "valuations");

  Future<void> getValuations(BuildContext context, {bool refresh = true}) async {
    await Future.delayed(Duration.zero);
    try {
      if (refresh) setLoading(true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      final result = await service.getExcelTable(client: client);
      valuations = result.map((item) => Valuation.fromJson(item)).toList();
      debugPrint("Fetched ${valuations.length} Valuation record(s) from Excel successfully.");
      notifyListeners();
    } catch (e) {
      if (refresh) {
        valuations = [];
      }
      debugPrint("Failed to fetch Valuations: ${e.toString()}");
    } finally {
      setLoading(false);
    }
  }

  Valuation getSelectedValuation() {
    return allValutions.firstWhere((report) => report.id == selectedItem, orElse: () => Valuation.fromJson({}));
  }

  List<Valuation> getSearchResults({String query = "", String filter = ""}) {
    query = normalizeString(query);
    var result = allValutions.where(
      (val) => normalizeString(
        [val.reportReference, val.dateOfInspection, val.village, val.taluk, val.mortgagorDetail, val.fileAllocationDetail].join(' '),
      ).contains(query),
    );
    if (filter.toLowerCase() == "template") {
      result = result.where((val) => val.status.toLowerCase() == "template");
    } else {
      result = result.where((val) => val.status.toLowerCase() != "template");
      switch (filter.toLowerCase()) {
        case "in progress":
          result = result.where((val) => val.status.toLowerCase() == "in progress" || val.status.toLowerCase() == "draft");
          break;
        case "site visited":
          result = result.where((val) => val.siteVisited && val.status.toLowerCase() != "completed");
          break;
        case "completed":
          result = result.where((val) => val.status.toLowerCase() == "completed");
          break;
        case "drafts":
          result = result.where((val) => val.status.toLowerCase() == "draft");
          break;
        case "trash":
          result = result.where((val) => val.status.toLowerCase() == "trash");
          break;
        case "all":
        default:
          result = result.where((val) => val.status.toLowerCase() != "trash");
          break;
      }
    }
    return result.toList();
  }

  Future<bool> addValuations(BuildContext context, Valuation newValuation) async {
    var success = false;
    try {
      setCreating(true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      final values = await service.generateTableValues(client: client, data: newValuation.toJson());
      await service.addToExcelTable(client: client, values: values);
      debugPrint("New Valuation added to Excel table successfully.");
      valuations = [newValuation, ...valuations];
      getValuations(context, refresh: false);
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
      final values = await service.generateTableValues(client: client, data: valuation.toJson());
      await service.updateExcelTableRow(client: client, index: valuation.id, values: values);
      debugPrint("Valuation ${valuation.reportReference} updated in Excel table successfully.");
      valuations[valuations.indexWhere((v) => v.id == valuation.id)] = valuation;
      getValuations(context, refresh: false);
      success = true;
    } catch (e) {
      debugPrint("Failed to update Valuation: ${e.toString()}");
    } finally {
      setCreating(false);
    }
    return success;
  }

  Future<void> deleteValuation(BuildContext context, Valuation valuation) async {
    try {
      setDeleting(true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      await service.deleteExcelTableRow(client: client, index: valuation.id);
      debugPrint("Valuation ${valuation.reportReference} deleted from Excel table successfully.");
      valuations.removeWhere((v) => v.id == valuation.id);
      getValuations(context, refresh: false);
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

  Future<void> getDrafts() async {
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

  Future<void> createOrUpdateDraft(Valuation valuation) async {
    try {
      await draftService.put(valuation.id, valuation.toJson());
      debugPrint("Saved draft ${valuation.id} to drafts.");
      getDrafts();
    } catch (e) {
      debugPrint("Failed to save as drafts: ${e.toString()}");
    }
  }

  Future<void> deleteDraft(String? id) async {
    if (id == null) {
      debugPrint("Failed to delete draft. id not provided.");
      return;
    }
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

  Future<void> getArchivedValuations(BuildContext context, {bool refresh = true}) async {
    await Future.delayed(Duration.zero);
    try {
      if (refresh) setLoading(true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      final result = await archiveService.getExcelTable(client: client);
      archived = result.map((item) => Valuation.fromJson(item)).toList();
      debugPrint("Fetched ${archived.length} archived Valuation record(s) from Excel successfully.");
      notifyListeners();
    } catch (e) {
      if (refresh) {
        archived = [];
      }
      debugPrint("Failed to fetch archived Valuations: ${e.toString()}");
    } finally {
      setLoading(false);
    }
  }

  Valuation getSelectedArchivedValuation() {
    return archived.firstWhere((report) => report.id == selectedItem, orElse: () => Valuation.fromJson({}));
  }

  List<Valuation> getArchivedSearchResults({String query = "", String filter = ""}) {
    query = normalizeString(query);
    return archived.reversed.where(
      (val) => normalizeString(
        [val.reportReference, val.dateOfInspection, val.village, val.taluk, val.mortgagorDetail, val.fileAllocationDetail].join(' '),
      ).contains(query),
    ).toList();
  }

  Future generateReport(BuildContext context, Valuation valuation, void Function(String message, {Status newStatus}) onStatusUpdate) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();

      onStatusUpdate("Generating Excel file");
      final newFileId = await service.createNewReportWorksheet(
        client: client,
        fileName: "${valuation.id} - ${valuation.reportReference} - Valuation Data",
      );

      onStatusUpdate("Linking values");
      final workbookLink = await service.getWorkbookLink(client: client);

      int column = 1;
      final tableValues = await service.generateTableValues(client: client, data: valuation.toJson());
      final values =
          tableValues.map((val) {
            final row = int.parse(valuation.id) + 2;
            final columnLetter = getExcelColumn(column++);
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
