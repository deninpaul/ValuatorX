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

  static final editableFields = [
    "Lattitude",
    "Longitude",
    "Land Rate/ Range per Cent",
    "Type of Land",
    "Size of land considered / Remarks",
    "Month of Visit",
    "Year Of Visit",
    "Road",
  ];

  factory LandRate.fromJson(Map<String, dynamic> json) {
    return LandRate(
      id: json["id"],
      slNo: json["SL No"].toString(),
      latitude: json["Lattitude"].toString(),
      longitude: json["Longitude"].toString(),
      landRatePerCent: json["Land Rate/ Range per Cent"].toString(),
      landType: json["Type of Land"].toString(),
      landSizeRemarks: json["Size of land considered / Remarks"].toString(),
      monthOfVisit: json["Month of Visit"].toString(),
      yearOfVisit: json["Year Of Visit"].toString(),
      road: json["Road"].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "SL No": slNo,
      "Lattitude": latitude,
      "Longitude": longitude,
      "Land Rate/ Range per Cent": landRatePerCent,
      "Type of Land": landType,
      "Size of land considered / Remarks": landSizeRemarks,
      "Month of Visit": monthOfVisit,
      "Year Of Visit": yearOfVisit,
      "Road": road,
    };
  }

  List toList() {
    return [slNo, latitude, longitude, landRatePerCent, landType, landSizeRemarks, monthOfVisit, yearOfVisit, road];
  }
}
