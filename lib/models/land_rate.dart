// ignore_for_file: constant_identifier_names

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:valuatorx/utils/common.dart';

class LandRate {
  final String id;
  final String slNo;
  final String latitude;
  final String longitude;
  final String landRatePerCent;
  final String landType;
  final String landSizeRemarks;
  final String monthOfVisit;
  final String yearOfVisit;
  final String road;
  final String author;

  LandRate({
    required this.id,
    required this.slNo,
    required this.latitude,
    required this.longitude,
    required this.landRatePerCent,
    required this.landType,
    required this.landSizeRemarks,
    required this.monthOfVisit,
    required this.yearOfVisit,
    required this.road,
    required this.author,
  });

  static const String ID = "id";
  static const String SL_NO = "SL No";
  static const String COORDINATES = "Coordinates in DD";
  static const String LATITUDE = "Lattitude";
  static const String LONGITUDE = "Longitude";
  static const String LAND_RATE_PER_CENT = "Land Rate/ per Cent";
  static const String LAND_TYPE = "Type of Land";
  static const String LAND_SIZE_REMARKS = "Size of land considered";
  static const String MONTH_OF_VISIT = "Month of Visit";
  static const String YEAR_OF_VISIT = "Year Of Visit";
  static const String ROAD = "Road";
  static const String AUTHOR = "Author";

  String get coordinates => "$latitude, $longitude";

  static const editableFields = [
    SL_NO,
    LATITUDE,
    LONGITUDE,
    LAND_RATE_PER_CENT,
    LAND_TYPE,
    LAND_SIZE_REMARKS,
    MONTH_OF_VISIT,
    YEAR_OF_VISIT,
    ROAD,
    AUTHOR,
  ];

  static const List<String> landTypeOptions = ["Residential", "Commercial", "Industrial", "Residential & Commercial", "Agricultural"];

  static const List<String> roadOptions = [
    "PWD",
    "Panchayath",
    "Private",
    "Muncipal",
    "Coorporation",
    "Land Locked Land",
    "No Vehicular Access",
  ];

  static const List<String> monthOptions = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  factory LandRate.fromJson(Map<String, dynamic> json) {
    final List<String> coordinates = (json[COORDINATES] ?? "").toString().split(',');
    return LandRate(
      id: (json[ID] ?? ""),
      slNo: (json[SL_NO] ?? "").toString(),
      latitude: coordinates.length == 2 ? coordinates[0].trim() : "",
      longitude: coordinates.length == 2 ? coordinates[1].trim() : "",
      landRatePerCent: (json[LAND_RATE_PER_CENT] ?? "").toString(),
      landType: (json[LAND_TYPE] ?? "").toString(),
      landSizeRemarks: (json[LAND_SIZE_REMARKS] ?? "").toString(),
      monthOfVisit: (json[MONTH_OF_VISIT] ?? "").toString(),
      yearOfVisit: (json[YEAR_OF_VISIT] ?? "").toString(),
      road: (json[ROAD] ?? "").toString(),
      author: (json[AUTHOR] ?? "").toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ID: id,
      SL_NO: slNo,
      LATITUDE: latitude,
      LONGITUDE: longitude,
      LAND_RATE_PER_CENT: landRatePerCent,
      LAND_TYPE: landType,
      LAND_SIZE_REMARKS: landSizeRemarks,
      MONTH_OF_VISIT: monthOfVisit,
      YEAR_OF_VISIT: yearOfVisit,
      ROAD: road,
      AUTHOR: author,
    };
  }

  List<dynamic> toList() {
    return [slNo, coordinates, landRatePerCent, landType, landSizeRemarks, monthOfVisit, yearOfVisit, road];
  }

  bool equal(LandRate val) {
    final mapA = toJson()..remove(ID);
    final mapB = val.toJson()..remove(ID);
    const eq = DeepCollectionEquality();
    return eq.equals(mapA, mapB);
  }

  static const String TABLE1 = "AntoPaul";
  static const String TABLE2 = "Siby";
  static const String TABLE3 = "Riyaf";
  static const String TABLE4 = "Sam";
  static const List<String> tables = [TABLE1, TABLE2, TABLE3, TABLE4];
  static MapColors getMapColors(ColorScheme scheme, String tableName) {
    switch (tableName) {
      case TABLE1:
        return MapColors(clusterFill: scheme.secondaryContainer, clusterStroke: scheme.primary, markerFill: scheme.secondaryFixedDim);
      case TABLE2:
        return MapColors(clusterFill: scheme.errorContainer, clusterStroke: scheme.error, markerFill: darkenColor(scheme.errorContainer));
      case TABLE3:
        return MapColors(clusterFill: scheme.tertiaryContainer, clusterStroke: scheme.tertiary, markerFill: scheme.tertiaryFixedDim);
      case TABLE4:
      default:
        return MapColors(clusterFill: scheme.primaryContainer, clusterStroke: scheme.primary, markerFill: scheme.primaryFixedDim);
    }
  }
}

class MapColors {
  final Color clusterFill;
  final Color clusterStroke;
  final Color markerFill;

  MapColors({required this.clusterFill, required this.clusterStroke, required this.markerFill});
}
