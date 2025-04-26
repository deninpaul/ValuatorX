// ignore_for_file: constant_identifier_names

class LandRate {
  final int id;
  final String slNo;
  final String latitude;
  final String longitude;
  final String landRatePerCent;
  final String landType;
  final String landSizeRemarks;
  final String monthOfVisit;
  final String yearOfVisit;
  final String road;

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
  });

  static const String ID = "id";
  static const String SL_NO = "SL No";
  static const String LATITUDE = "Lattitude";
  static const String LONGITUDE = "Longitude";
  static const String LAND_RATE_PER_CENT = "Land Rate/ Range per Cent";
  static const String LAND_TYPE = "Type of Land";
  static const String LAND_SIZE_REMARKS = "Size of land considered / Remarks";
  static const String MONTH_OF_VISIT = "Month of Visit";
  static const String YEAR_OF_VISIT = "Year Of Visit";
  static const String ROAD = "Road";

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
  ];

  static const List<String> landTypeOptions = [
    "Residential",
    "Commercial",
    "Industrial",
    "Residential & Commercial",
    "Agricultural",
  ];

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
    return LandRate(
      id: json[ID],
      slNo: json[SL_NO].toString(),
      latitude: json[LATITUDE].toString(),
      longitude: json[LONGITUDE].toString(),
      landRatePerCent: json[LAND_RATE_PER_CENT].toString(),
      landType: json[LAND_TYPE].toString(),
      landSizeRemarks: json[LAND_SIZE_REMARKS].toString(),
      monthOfVisit: json[MONTH_OF_VISIT].toString(),
      yearOfVisit: json[YEAR_OF_VISIT].toString(),
      road: json[ROAD].toString(),
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
    };
  }

  List<dynamic> toList() {
    return [slNo, latitude, longitude, landRatePerCent, landType, landSizeRemarks, monthOfVisit, yearOfVisit, road];
  }
}
