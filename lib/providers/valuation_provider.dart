import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/modals/land_rate.dart';
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

  getLandRates(BuildContext context, {bool refresh = true}) async {
    try {
      if (refresh) setLoading(true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      var result = await service.getExcelTable(client: client);
      valuations = result.map((item) => Valuation.fromJson(item)).toList();
      debugPrint("Fetched ${valuations.length} Land Rate record(s) from Excel successfully.");
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to fetch Land Rates: ${e.toString()}");
    } finally {
      setLoading(false);
    }
  }

  Valuation getSelectedLandRate() {
    return valuations.firstWhere((report) => report.id == selectedItem);
  }

  addLandRate(BuildContext context, LandRate newLandRate) async {
    try {
      setCreating(true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      await service.addToExcelTable(client: client, values: newLandRate.toList());
      debugPrint("New Land Rate added to Excel table successfully.");
      await getLandRates(context, refresh: false);
    } catch (e) {
      debugPrint("Failed to add Land Rate: ${e.toString()}");
    } finally {
      setCreating(false);
    }
  }

  updateLandRate(BuildContext context, LandRate landRate) async {
    try {
      setCreating(true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      await service.updateExcelTableRow(client: client, index: landRate.id, values: landRate.toList());
      debugPrint("Land Rate ${landRate.slNo} updated in Excel table successfully.");
      await getLandRates(context, refresh: false);
    } catch (e) {
      debugPrint("Failed to update Land Rate: ${e.toString()}");
    } finally {
      setCreating(false);
    }
  }

  deleteLandRate(BuildContext context, LandRate landRate) async {
    try {
      setDeleting(true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      await service.deleteExcelTableRow(client: client, index: landRate.id);
      debugPrint("Land Rate ${landRate.slNo} deleted from Excel table successfully.");
    } catch (e) {
      debugPrint("Failed to delete Land Rate: ${e.toString()}");
    } finally {
      setDeleting(false);
    }
  }

  // int generateIndex() {
  //   return landRates.isEmpty ? -1 : landRates.last.id + 1;
  // }

  void setSelectedItem(int value) {
    selectedItem = value;
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setCreating(bool value) {
    isCreating = value;
    notifyListeners();
  }

  void setDeleting(bool value) {
    isDeleting = value;
    notifyListeners();
  }
}
