import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/modals/land_rate.dart';
import 'package:valuatorx/providers/auth_provider.dart';
import 'package:valuatorx/utils/excel_service.dart';

class LandRateProvider extends ChangeNotifier {
  List<LandRate> landRates = [];
  bool isLoading = false;

  final LandRateService service = LandRateService();

  getLandRates(BuildContext context, {bool refresh = true}) async {
    try {
      if (refresh) setLoading(true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      var result = await service.getExcelTable(client: client);
      landRates = result.map((item) => LandRate.fromJson(item)).toList();
      debugPrint("Fetched ${landRates.length} Land Rate record(s) from Excel successfully.");
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to fetch Land Rates: ${e.toString()}");
    } finally {
      setLoading(false);
    }
  }

  addLandRate(BuildContext context, LandRate newLandRate) async {
    try {
      setLoading(true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      await service.addToExcelTable(client: client, values: newLandRate.toList());
      debugPrint("New Land Rate added to Excel table successfully.");
    } catch (e) {
      debugPrint("Failed to add Land Rate: ${e.toString()}");
    } finally {
      setLoading(false);
    }
  }

  int generateIndex() {
    return landRates[landRates.length - 1].id + 1;
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
