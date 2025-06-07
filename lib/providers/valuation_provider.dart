import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/modals/valuation.dart';
import 'package:valuatorx/providers/auth_provider.dart';
import 'package:valuatorx/utils/excel_service.dart';

class ValuationProvider extends ChangeNotifier {
  List<Valuation> valuations = [];
  bool isLoading = false;
  bool isCreating = false;
  bool isDeleting = false;
  int selectedItem = -1;

  final ValuationService service = ValuationService();

  getValuations(BuildContext context, {bool refresh = true}) async {
    try {
      if (refresh) setLoading(true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      var result = await service.getExcelTable(client: client);
      valuations = result.map((item) => Valuation.fromJson(item)).toList();
      debugPrint("Fetched ${valuations.length} Valuation record(s) from Excel successfully.");
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to fetch Valuations: ${e.toString()}");
    } finally {
      setLoading(false);
    }
  }

  Valuation getSelectedValuation() {
    return valuations.firstWhere((report) => report.id == selectedItem);
  }

  addValuations(BuildContext context, Valuation newValuation) async {
    try {
      setCreating(true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      await service.addToExcelTable(client: client, values: newValuation.toList());
      debugPrint("New Valuation added to Excel table successfully.");
      await getValuations(context, refresh: false);
    } catch (e) {
      debugPrint("Failed to add Valuation: ${e.toString()}");
    } finally {
      setCreating(false);
    }
  }

  updateValuation(BuildContext context, Valuation valuation) async {
    try {
      setCreating(true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      await service.updateExcelTableRow(client: client, index: valuation.id, values: valuation.toList());
      debugPrint("Valuation ${valuation.reportName} updated in Excel table successfully.");
      await getValuations(context, refresh: false);
    } catch (e) {
      debugPrint("Failed to update Valuation: ${e.toString()}");
    } finally {
      setCreating(false);
    }
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

  Future<String> uploadImage(BuildContext context, File image) async {
    String id = "";
    final fileData = await image.readAsBytes();
    final fileName = image.path.split('/').last;
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      id = await service.uploadFile(client: client, name: fileName, file: fileData);
    } catch (e) {
      debugPrint("Failed to upload image: ${e.toString()}");
    }
    return id;
  }

  Future<List<String>> getImages(BuildContext context, List<String> ids) async {
    List<String> downloadLinks = [];
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      for (var id in ids) {
        final String downloadLink = await service.getFileDownloadLink(client: client, id: id);
        downloadLinks.add(downloadLink);
      }
      return downloadLinks;
    } catch (e) {
      debugPrint("Failed to download image: ${e.toString()}");
    }
    return downloadLinks;
  }

  int generateIndex() {
    return valuations.isEmpty ? -1 : valuations.last.id + 1;
  }

  void setSelectedItem(int value, {bool notify = true}) {
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
