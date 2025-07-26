import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/models/land_rate.dart';
import 'package:valuatorx/providers/auth_provider.dart';
import 'package:valuatorx/services/land_rate_service.dart';
import 'package:valuatorx/utils/common.dart';

class LandRateProvider extends ChangeNotifier {
  List<LandRate> landRates = [];
  bool isLoading = false;
  bool isCreating = false;
  bool isDeleting = false;
  String selectedItem = "";
  String selectedTable = "";

  final Map<String, LandRateService> services = {for (final table in LandRate.tables) table: LandRateService(tableName: table)};

  getLandRates(BuildContext context, {bool refresh = true}) async {
    try {
      if (refresh) setLoading(true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      var result = await Future.wait(LandRate.tables.map((table) => services[table]!.getExcelTable(client: client)));
      landRates = result.expand((list) => list).map((item) => LandRate.fromJson(item)).toList();
      debugPrint("Fetched ${landRates.length} Land Rate record(s) from Excel successfully.");
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to fetch Land Rates: ${e.toString()}");
    } finally {
      setLoading(false);
    }
  }

  LandRate getSelectedLandRate() {
    return landRates.firstWhere(
      (landRate) => landRate.id.toString() == selectedItem && landRate.author == selectedTable,
      orElse: () => LandRate.fromJson({}),
    );
  }

  List<LandRate> getSearchResults(String query, String filter) {
    final parsedLatLng = parseLatLng(query);
    final parsedInt = int.tryParse(query);
    if (parsedLatLng != null) {
      final distance = Distance();
      return landRates
          .where((val) {
            try {
              return distance(parsedLatLng, LatLng(double.parse(val.latitude), double.parse(val.longitude))) <= 2000;
            } catch (e) {
              return false;
            }
          })
          .where((val) => val.author == filter)
          .toList();
    }
    if (parsedInt != null) {
      return landRates.where((val) => int.tryParse(val.slNo) == parsedInt).where((val) => val.author == filter).toList();
    }
    return landRates
        .where((val) => "${val.landType} ${val.road} ${val.slNo}".toLowerCase().contains(query.toLowerCase()))
        .where((val) => val.author == filter)
        .toList();
  }

  addLandRate(BuildContext context, LandRate newLandRate) async {
    try {
      setCreating(true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final client = await authProvider.getClient();
      await services[newLandRate.author]!.addToExcelTable(client: client, values: newLandRate.toList());
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
      await services[landRate.author]!.updateExcelTableRow(client: client, index: landRate.id.toString(), values: landRate.toList());
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
      await services[landRate.author]!.deleteExcelTableRow(client: client, index: landRate.id.toString());
      debugPrint("Land Rate ${landRate.slNo} deleted from Excel table successfully.");
      await getLandRates(context, refresh: false);
    } catch (e) {
      debugPrint("Failed to delete Land Rate: ${e.toString()}");
    } finally {
      setDeleting(false);
    }
  }

  String generateIndex() {
    final ids = landRates.where((rate) => rate.author == selectedTable).map((e) => int.tryParse(e.slNo)).whereType<int>().toList();
    return (ids.isEmpty ? 1 : ids.last + 1).toString();
  }

  void setSelectedItem(String id, String table, {bool notify = true}) {
    selectedItem = id;
    selectedTable = table;
    if (notify) {
      notifyListeners();
    }
  }

  void setSelectedTable(String table) {
    selectedTable = table;
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
