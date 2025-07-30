// ignore_for_file: constant_identifier_names

import 'package:collection/collection.dart';
import 'package:valuatorx/utils/common.dart';

class Valuation {
  String status;
  String reportLink;
  final String id;
  final String reportReference;
  final String fileAllocationDetail;
  final String dateOfInspection;
  final String mortgagorDetail;
  final String mortgagorNumber;
  final String deedOwnerDetail;
  final String legalReportDetail;
  final String deedDocumentDetails;
  final String possessionCertificateDetails;
  final String locationSketchDetails;
  final String propertyTaxCertificateDetails;
  final String buildingTaxDetails;
  final String buildingApprovalReference;
  final String surveyNo1;
  final String area1;
  final String surveyNo2;
  final String area2;
  final String surveyNo3;
  final String area3;
  final String surveyNo4;
  final String area4;
  final String village;
  final String taluk;
  final String panchayath;
  final String mainCenter;
  final String nearbyTown;
  final String propertyLandmark;
  final String latitude;
  final String longitude;
  final String eastActual;
  final String eastDeed;
  final String southActual;
  final String southDeed;
  final String westActual;
  final String westDeed;
  final String northActual;
  final String northDeed;
  final String roadDetails;
  final String houseNumber;
  final String electricityConsumerNo;
  final String buildingDescription;
  final String yearOfConstruction;
  final String buildingType;
  final String constructionType;
  final String exteriorCondition;
  final String interiorCondition;
  final String foundationAndBasement;
  final String wallDetails;
  final String roofing;
  final String flooring;
  final String ceilingFinish;
  final String windows;
  final String doors;
  final String rccWorks;
  final String plinthAreaGF;
  final String replacementRateGF;
  final String plinthAreaFF;
  final String replacementRateFF;
  final String plinthAreaSF;
  final String replacementRateSF;
  final String plinthAreaTF;
  final String replacementRateTF;
  final String areaRateCenter;
  final String propertyAreaRate;
  final String buildingReplacementRate;
  final String photos;
  final String remarks;

  Valuation({
    required this.id,
    required this.reportReference,
    required this.dateOfInspection,
    required this.status,
    required this.reportLink,
    required this.fileAllocationDetail,
    required this.mortgagorDetail,
    required this.mortgagorNumber,
    required this.deedOwnerDetail,
    required this.legalReportDetail,
    required this.deedDocumentDetails,
    required this.possessionCertificateDetails,
    required this.locationSketchDetails,
    required this.propertyTaxCertificateDetails,
    required this.buildingTaxDetails,
    required this.buildingApprovalReference,
    required this.surveyNo1,
    required this.area1,
    required this.surveyNo2,
    required this.area2,
    required this.surveyNo3,
    required this.area3,
    required this.surveyNo4,
    required this.area4,
    required this.village,
    required this.taluk,
    required this.panchayath,
    required this.mainCenter,
    required this.nearbyTown,
    required this.propertyLandmark,
    required this.latitude,
    required this.longitude,
    required this.eastActual,
    required this.eastDeed,
    required this.southActual,
    required this.southDeed,
    required this.westActual,
    required this.westDeed,
    required this.northActual,
    required this.northDeed,
    required this.roadDetails,
    required this.houseNumber,
    required this.electricityConsumerNo,
    required this.buildingDescription,
    required this.yearOfConstruction,
    required this.buildingType,
    required this.constructionType,
    required this.exteriorCondition,
    required this.interiorCondition,
    required this.foundationAndBasement,
    required this.wallDetails,
    required this.roofing,
    required this.flooring,
    required this.ceilingFinish,
    required this.windows,
    required this.doors,
    required this.rccWorks,
    required this.plinthAreaGF,
    required this.replacementRateGF,
    required this.plinthAreaFF,
    required this.replacementRateFF,
    required this.plinthAreaSF,
    required this.replacementRateSF,
    required this.plinthAreaTF,
    required this.replacementRateTF,
    required this.areaRateCenter,
    required this.propertyAreaRate,
    required this.buildingReplacementRate,
    required this.photos,
    required this.remarks,
  });

  static const String ID = "id";
  static const String REPORT_REFERENCE = "Report Reference No.";
  static const String DATE_OF_INSPECTION = "Date of Inspection";
  static const String STATUS = "Status";
  static const String FILE_ALLOCATION_DETAIL = "Bank/File Allocation Details";
  static const String MORTGAGOR_DETAIL = "Mortgagor Details";
  static const String MORTGAGOR_MOBILE = "Mortgagor Phone No.";
  static const String DEED_OWNER_DETAIL = "Deed Owner Details";
  static const String LEGAL_REPORT_REFERENCE = "Legal Report Date/Clause No.";
  static const String DEED_DOCUMENT_DETAILS = "Deed Number/Data/SRO";
  static const String POCCESSION_CERTIFICATE_DETAILS = "Poccession Certificate Details";
  static const String LOCATION_SKETCH_DETAILS = "Location Sketch Details";
  static const String PROPERTY_TAX_CERTICATE_DETAILS = "Property Tax Certicate Details";
  static const String BUILDING_TAX_CERTIFICATE_DETAILS = "Building Tax Details";
  static const String BUILDING_APPROVAL_REFERENCE = "Building Approval Reference";
  static const String SURVEY_NO_RE_SY_NO_1 = "Survey No./ Re. Sy. No. - 1";
  static const String AREA_IN_ARE_1 = "Area (in Are) - 1";
  static const String SURVEY_NO_RE_SY_NO_2 = "Survey No./ Re. Sy. No. - 2";
  static const String AREA_IN_ARE_2 = "Area (in Are) - 2";
  static const String SURVEY_NO_RE_SY_NO_3 = "Survey No./ Re. Sy. No. - 3";
  static const String AREA_IN_ARE_3 = "Area (in Are) - 3";
  static const String SURVEY_NO_RE_SY_NO_4 = "Survey No./ Re. Sy. No. - 4";
  static const String AREA_IN_ARE_4 = "Area (in Are) - 4";
  static const String VILLAGE = "Village";
  static const String TALUK = "Taluk";
  static const String PANCHAYATH = "Panchayath";
  static const String MAIN_CENTER = "Dhesham/Main Center";
  static const String NEARBY_TOWN = "Nearby Town";
  static const String LANDMARK_OF_THE_PROPERTY = "Landmark Reference";
  static const String LATTITUDE = "Lattitude";
  static const String LONGITUDE = "Longitude";
  static const String EAST_ACTUALS = "East - Actuals";
  static const String EAST_AS_PER_DEED = "East - As per Deed";
  static const String SOUTH_ACTUALS = "South - Actuals";
  static const String SOUTH_AS_PER_DEED = "South - As per Deed";
  static const String WEST_ACTUALS = "West - Actuals";
  static const String WEST_AS_PER_DEED = "West - As per Deed";
  static const String NORTH_ACTUALS = "North - Actuals";
  static const String NORTH_AS_PER_DEED = "North - As per Deed";
  static const String ROAD_DETAILS = "Road Access Detail";
  static const String HOUSE_NO_DOOR_NO = "House No./ Door No.";
  static const String ELECTRICITY_CONSUMER_NO = "Electricity Consumer no.";
  static const String BUILDING_DESCRIPTION = "Building Description";
  static const String YEAR_OF_CONSTRUCTION = "Year of Construction";
  static const String TYPE_OF_BUILDING = "Type of Building";
  static const String TYPE_OF_CONSTRUCTION = "Type of Construction";
  static const String CONDITION_OF_BUILDING_EXTERIOR = "Condition of Building - Exterior";
  static const String CONDITION_OF_BUILDING_INTERIOR = "Condition of Building - Interior";
  static const String FOUNDATION_BASEMENT = "Foundation & Basement";
  static const String RCC_WORKS = "RCC Roof Protection";
  static const String WALL_DETAILS = "Walls";
  static const String CEILING_FINISH = "Ceiling Finish";
  static const String FLOORING = "Flooring";
  static const String DOORS = "Doors";
  static const String WINDOWS = "Windows";
  static const String ROOFING = "Roof Covering";
  static const String PLINT_AREA_GF = "GF - Plint area";
  static const String REPLACEMENT_RATE_GF = "GF - Replacement Rate";
  static const String PLINTH_AREA_FF = "FF - Plinth area";
  static const String REPLACEMENT_RATE_FF = "FF - Replacement Rate";
  static const String PLINTH_AREA_SF = "SF - Plinth area";
  static const String REPLACEMENT_RATE_SF = "SF - Replacement Rate";
  static const String PLINTH_AREA_TF = "TF - Plinth area";
  static const String REPLACEMENT_RATE_TF = "TF - Replacement Rate";
  static const String PREVAILING_AREA_RATE_AT_CENTER = "Center Previaling Land Rate/ cent";
  static const String BUILDING_REPLACEMENT_RATE = "Building Replacement rate/ sft.";
  static const String PROPERTY_AREA_RATE = "Property Land Rate/ cent";
  static const String PHOTOS = "Photos";
  static const String REMARKS = "Remarks";
  static const String REPORT_LINK = "Report link";

  factory Valuation.fromJson(Map<String, dynamic> json) {
    return Valuation(
      id: (json[ID] ?? "").toString(),
      reportReference: (json[REPORT_REFERENCE] ?? "").toString(),
      fileAllocationDetail: (json[FILE_ALLOCATION_DETAIL] ?? "").toString(),
      dateOfInspection: (json[DATE_OF_INSPECTION] ?? "").toString(),
      status: (json[STATUS] ?? "").toString(),
      mortgagorDetail: (json[MORTGAGOR_DETAIL] ?? "").toString(),
      mortgagorNumber: (json[MORTGAGOR_MOBILE] ?? "").toString(),
      deedOwnerDetail: (json[DEED_OWNER_DETAIL] ?? "").toString(),
      legalReportDetail: (json[LEGAL_REPORT_REFERENCE] ?? "").toString(),
      deedDocumentDetails: (json[DEED_DOCUMENT_DETAILS] ?? "").toString(),
      possessionCertificateDetails: (json[POCCESSION_CERTIFICATE_DETAILS] ?? "").toString(),
      locationSketchDetails: (json[LOCATION_SKETCH_DETAILS] ?? "").toString(),
      propertyTaxCertificateDetails: (json[PROPERTY_TAX_CERTICATE_DETAILS] ?? "").toString(),
      buildingTaxDetails: (json[BUILDING_TAX_CERTIFICATE_DETAILS] ?? "").toString(),
      buildingApprovalReference: (json[BUILDING_APPROVAL_REFERENCE] ?? "").toString(),
      surveyNo1: (json[SURVEY_NO_RE_SY_NO_1] ?? "").toString(),
      area1: (json[AREA_IN_ARE_1] ?? "").toString(),
      surveyNo2: (json[SURVEY_NO_RE_SY_NO_2] ?? "").toString(),
      area2: (json[AREA_IN_ARE_2] ?? "").toString(),
      surveyNo3: (json[SURVEY_NO_RE_SY_NO_3] ?? "").toString(),
      area3: (json[AREA_IN_ARE_3] ?? "").toString(),
      surveyNo4: (json[SURVEY_NO_RE_SY_NO_4] ?? "").toString(),
      area4: (json[AREA_IN_ARE_4] ?? "").toString(),
      village: (json[VILLAGE] ?? "").toString(),
      taluk: (json[TALUK] ?? "").toString(),
      panchayath: (json[PANCHAYATH] ?? "").toString(),
      mainCenter: (json[MAIN_CENTER] ?? "").toString(),
      nearbyTown: (json[NEARBY_TOWN] ?? "").toString(),
      propertyLandmark: (json[LANDMARK_OF_THE_PROPERTY] ?? "").toString(),
      latitude: (json[LATTITUDE] ?? "").toString(),
      longitude: (json[LONGITUDE] ?? "").toString(),
      eastActual: (json[EAST_ACTUALS] ?? "").toString(),
      eastDeed: (json[EAST_AS_PER_DEED] ?? "").toString(),
      southActual: (json[SOUTH_ACTUALS] ?? "").toString(),
      southDeed: (json[SOUTH_AS_PER_DEED] ?? "").toString(),
      westActual: (json[WEST_ACTUALS] ?? "").toString(),
      westDeed: (json[WEST_AS_PER_DEED] ?? "").toString(),
      northActual: (json[NORTH_ACTUALS] ?? "").toString(),
      northDeed: (json[NORTH_AS_PER_DEED] ?? "").toString(),
      roadDetails: (json[ROAD_DETAILS] ?? "").toString(),
      houseNumber: (json[HOUSE_NO_DOOR_NO] ?? "").toString(),
      electricityConsumerNo: (json[ELECTRICITY_CONSUMER_NO] ?? "").toString(),
      buildingDescription: (json[BUILDING_DESCRIPTION] ?? "").toString(),
      yearOfConstruction: (json[YEAR_OF_CONSTRUCTION] ?? "").toString(),
      constructionType: (json[TYPE_OF_CONSTRUCTION] ?? "").toString(),
      buildingType: (json[TYPE_OF_BUILDING] ?? "").toString(),
      exteriorCondition: (json[CONDITION_OF_BUILDING_EXTERIOR] ?? "").toString(),
      interiorCondition: (json[CONDITION_OF_BUILDING_INTERIOR] ?? "").toString(),
      foundationAndBasement: (json[FOUNDATION_BASEMENT] ?? "").toString(),
      rccWorks: (json[RCC_WORKS] ?? "").toString(),
      wallDetails: (json[WALL_DETAILS] ?? "").toString(),
      flooring: (json[FLOORING] ?? "").toString(),
      doors: (json[DOORS] ?? "").toString(),
      windows: (json[WINDOWS] ?? "").toString(),
      ceilingFinish: (json[CEILING_FINISH] ?? "").toString(),
      roofing: (json[ROOFING] ?? "").toString(),
      plinthAreaGF: (json[PLINT_AREA_GF] ?? "").toString(),
      replacementRateGF: (json[REPLACEMENT_RATE_GF] ?? "").toString(),
      plinthAreaFF: (json[PLINTH_AREA_FF] ?? "").toString(),
      replacementRateFF: (json[REPLACEMENT_RATE_FF] ?? "").toString(),
      plinthAreaSF: (json[PLINTH_AREA_SF] ?? "").toString(),
      replacementRateSF: (json[REPLACEMENT_RATE_SF] ?? "").toString(),
      plinthAreaTF: (json[PLINTH_AREA_TF] ?? "").toString(),
      replacementRateTF: (json[REPLACEMENT_RATE_TF] ?? "").toString(),
      areaRateCenter: (json[PREVAILING_AREA_RATE_AT_CENTER] ?? "").toString(),
      buildingReplacementRate: (json[BUILDING_REPLACEMENT_RATE] ?? "").toString(),
      propertyAreaRate: (json[PROPERTY_AREA_RATE] ?? "").toString(),
      photos: (json[PHOTOS] ?? "").toString(),
      remarks: (json[REMARKS] ?? "").toString(),
      reportLink: (json[REPORT_LINK] ?? "").toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ID: id,
      REPORT_REFERENCE: reportReference,
      DATE_OF_INSPECTION: dateOfInspection,
      STATUS: status,
      FILE_ALLOCATION_DETAIL: fileAllocationDetail,
      MORTGAGOR_DETAIL: mortgagorDetail,
      MORTGAGOR_MOBILE: mortgagorNumber,
      DEED_OWNER_DETAIL: deedOwnerDetail,
      DEED_DOCUMENT_DETAILS: deedDocumentDetails,
      LEGAL_REPORT_REFERENCE: legalReportDetail,
      POCCESSION_CERTIFICATE_DETAILS: possessionCertificateDetails,
      LOCATION_SKETCH_DETAILS: locationSketchDetails,
      PROPERTY_TAX_CERTICATE_DETAILS: propertyTaxCertificateDetails,
      BUILDING_TAX_CERTIFICATE_DETAILS: buildingTaxDetails,
      BUILDING_APPROVAL_REFERENCE: buildingApprovalReference,
      SURVEY_NO_RE_SY_NO_1: surveyNo1,
      AREA_IN_ARE_1: area1,
      SURVEY_NO_RE_SY_NO_2: surveyNo2,
      AREA_IN_ARE_2: area2,
      SURVEY_NO_RE_SY_NO_3: surveyNo3,
      AREA_IN_ARE_3: area3,
      SURVEY_NO_RE_SY_NO_4: surveyNo4,
      AREA_IN_ARE_4: area4,
      VILLAGE: village,
      TALUK: taluk,
      PANCHAYATH: panchayath,
      MAIN_CENTER: mainCenter,
      NEARBY_TOWN: nearbyTown,
      LANDMARK_OF_THE_PROPERTY: propertyLandmark,
      LATTITUDE: latitude,
      LONGITUDE: longitude,
      EAST_ACTUALS: eastActual,
      EAST_AS_PER_DEED: eastDeed,
      SOUTH_ACTUALS: southActual,
      SOUTH_AS_PER_DEED: southDeed,
      WEST_ACTUALS: westActual,
      WEST_AS_PER_DEED: westDeed,
      NORTH_ACTUALS: northActual,
      NORTH_AS_PER_DEED: northDeed,
      ROAD_DETAILS: roadDetails,
      HOUSE_NO_DOOR_NO: houseNumber,
      ELECTRICITY_CONSUMER_NO: electricityConsumerNo,
      BUILDING_DESCRIPTION: buildingDescription,
      YEAR_OF_CONSTRUCTION: yearOfConstruction,
      TYPE_OF_BUILDING: buildingType,
      TYPE_OF_CONSTRUCTION: constructionType,
      CONDITION_OF_BUILDING_EXTERIOR: exteriorCondition,
      CONDITION_OF_BUILDING_INTERIOR: interiorCondition,
      FOUNDATION_BASEMENT: foundationAndBasement,
      RCC_WORKS: rccWorks,
      WALL_DETAILS: wallDetails,
      FLOORING: flooring,
      DOORS: doors,
      WINDOWS: windows,
      CEILING_FINISH: ceilingFinish,
      ROOFING: roofing,
      PLINT_AREA_GF: plinthAreaGF,
      REPLACEMENT_RATE_GF: replacementRateGF,
      PLINTH_AREA_FF: plinthAreaFF,
      REPLACEMENT_RATE_FF: replacementRateFF,
      PLINTH_AREA_SF: plinthAreaSF,
      REPLACEMENT_RATE_SF: replacementRateSF,
      PLINTH_AREA_TF: plinthAreaTF,
      REPLACEMENT_RATE_TF: replacementRateTF,
      PREVAILING_AREA_RATE_AT_CENTER: areaRateCenter,
      BUILDING_REPLACEMENT_RATE: buildingReplacementRate,
      PROPERTY_AREA_RATE: propertyAreaRate,
      PHOTOS: photos,
      REMARKS: remarks,
      REPORT_LINK: reportLink,
    };
  }

  List<String?> toList() {
    List<String> list = [];
    for (var field in editableFields) {
      list.add((toJson()[field] ?? "").toString());
    }
    return list;
  }

  equal(Valuation val) {
    final mapA = toJson()..remove(STATUS)..remove(ID);
    final mapB = val.toJson()..remove(STATUS)..remove(ID);
    const eq = DeepCollectionEquality();
    return eq.equals(mapA, mapB);
  }

  String get subtitle => [village, taluk].where((e) => e.trim().isNotEmpty).join(', ');

  String get title =>
      reportReference.isNotEmpty ? "$reportReference - ${extractPersons(mortgagorDetail)}" : extractPersons(mortgagorDetail);

  bool get siteVisited =>
      (longitude.isNotEmpty && latitude.isNotEmpty && (houseNumber.trim().isNotEmpty || propertyAreaRate.trim().isNotEmpty)) &&
      (longitude != "0" && latitude != "0");

  static const editableFields = [
    REPORT_REFERENCE,
    DATE_OF_INSPECTION,
    STATUS,
    FILE_ALLOCATION_DETAIL,
    MORTGAGOR_DETAIL,
    MORTGAGOR_MOBILE,
    DEED_OWNER_DETAIL,
    DEED_DOCUMENT_DETAILS,
    LEGAL_REPORT_REFERENCE,
    POCCESSION_CERTIFICATE_DETAILS,
    LOCATION_SKETCH_DETAILS,
    PROPERTY_TAX_CERTICATE_DETAILS,
    BUILDING_TAX_CERTIFICATE_DETAILS,
    BUILDING_APPROVAL_REFERENCE,
    SURVEY_NO_RE_SY_NO_1,
    AREA_IN_ARE_1,
    SURVEY_NO_RE_SY_NO_2,
    AREA_IN_ARE_2,
    SURVEY_NO_RE_SY_NO_3,
    AREA_IN_ARE_3,
    SURVEY_NO_RE_SY_NO_4,
    AREA_IN_ARE_4,
    VILLAGE,
    TALUK,
    PANCHAYATH,
    MAIN_CENTER,
    NEARBY_TOWN,
    LANDMARK_OF_THE_PROPERTY,
    LATTITUDE,
    LONGITUDE,
    EAST_ACTUALS,
    EAST_AS_PER_DEED,
    SOUTH_ACTUALS,
    SOUTH_AS_PER_DEED,
    WEST_ACTUALS,
    WEST_AS_PER_DEED,
    NORTH_ACTUALS,
    NORTH_AS_PER_DEED,
    ROAD_DETAILS,
    HOUSE_NO_DOOR_NO,
    ELECTRICITY_CONSUMER_NO,
    BUILDING_DESCRIPTION,
    YEAR_OF_CONSTRUCTION,
    TYPE_OF_BUILDING,
    TYPE_OF_CONSTRUCTION,
    CONDITION_OF_BUILDING_EXTERIOR,
    CONDITION_OF_BUILDING_INTERIOR,
    FOUNDATION_BASEMENT,
    RCC_WORKS,
    WALL_DETAILS,
    FLOORING,
    DOORS,
    WINDOWS,
    CEILING_FINISH,
    ROOFING,
    PLINT_AREA_GF,
    REPLACEMENT_RATE_GF,
    PLINTH_AREA_FF,
    REPLACEMENT_RATE_FF,
    PLINTH_AREA_SF,
    REPLACEMENT_RATE_SF,
    PLINTH_AREA_TF,
    REPLACEMENT_RATE_TF,
    PREVAILING_AREA_RATE_AT_CENTER,
    BUILDING_REPLACEMENT_RATE,
    PROPERTY_AREA_RATE,
    PHOTOS,
    REMARKS,
  ];

  static const statusOptions = ["In progress", "Completed"];

  static const buildingTypeOptions = ["Residential", "Commercial", "Industrial", "-"];

  static const constructionTypeOptions = ["Loan bearing", "RCC Framed Structure", "Combined load bearing structure", "Steel structure", "-"];

  static const qualityOfConstructionOptions = ["Excellent", "Good", "Normal", "Poor", "-"];

  static const exteriorConditionOptions = ["Excellent", "Good", "Normal", "Poor", "-"];

  static const interiorConditionOptions = ["Excellent", "Good", "Normal", "Poor", "-"];

  static const foundationOptions = ["Random Rubble Masonry for foundation and basement", "Isolated footing with stub columns and plinth beam", "Combined foundation of strip footing, columns, random masonry and plinth beam", "-"];

  static const wallOptions = ["Lateriate Masonry in cement mortor with plaster", "Brick Masonry in cement mortor with plaster", "Concrete Block Masonry in cement mortor with plaster", "-"];

  static const roofOptions = ["Reinforced Concrete Slab", "Power coated GI Profile sheet on steel truss", "Mangalore tile on wooden truss", "-"];

  static const ceilingOptions = ["Cement mortor Plaster with acrylic paint", "False ceiling with acrylic paint", "-"];

  static const windowOptions = ["Wooden frame with glazed shutter", "Aluminimum frame with glazed shutter", "Steel frame with glazed steel shutter", "Concrete frame with aluminimum glazed shutter", "-"];

  static const doorOptions = ["Wooden frame with panelled wooden door", "Wooden frame with modular door", "Wooden frame with laminate plywood door", "-"];

  static const rccProtectionOptions = ["Cement mortar screed laid to slope", "GI powder coated tiled profile sheet on steel truss", "Designed mangalore tiles on steel truss", "Mangalore tiles laid on slope roof", "-"];
}
