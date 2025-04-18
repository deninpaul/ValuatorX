import 'package:flutter/material.dart';
import 'package:valuatorx/modals/land_rate.dart';
import 'package:valuatorx/utils/global.dart';
import 'package:valuatorx/utils/mocks.dart';

class LandRateProvider extends ChangeNotifier {
  List<LandRate> landRates = [];
  bool isLoading = false;

  Future<List<LandRate>> getLandRates() async {
    setLoading(true);

    var fieldsResponse = landRateMockFields;
    var rowsResponse = landRateMockValues;
    var result = parseTableToJson(fieldsData: fieldsResponse, rowsData: rowsResponse);
    // await Future.delayed(Duration(seconds: 1));
    
    landRates = result.map((item) => LandRate.fromJson(item)).toList();
    notifyListeners();
    setLoading(false);

    return landRates;
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
