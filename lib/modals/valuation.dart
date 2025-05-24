// ignore_for_file: constant_identifier_names

class Valuation {
  final int id;
  final String reportName;
  final String dateOfInspection;
  String status;
  final String bankDetails;
  final String ownerDetails;
  final String propertyPossessionAddress;
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
  final String landCategory;
  final String eastActual;
  final String eastDeed;
  final String southActual;
  final String southDeed;
  final String westActual;
  final String westDeed;
  final String northActual;
  final String northDeed;
  final String legalReportReference;
  final String buildingApprovalReference;
  final String deedRegDetails;
  final String possessionCertificateDetails;
  final String locationSketchDetails;
  final String propertyTaxCertificateDetails;
  final String buildingTaxCertificateDetails;
  final String latitude;
  final String longitude;
  final String encumbranceReference;
  final String topographyAndShape;
  final String houseNumber;
  final String panchayath;
  final String electricityConsumerNo;
  final String ksebDivision;
  final String yearOfConstruction;
  final String qualityOfConstruction;
  final String buildingType;
  final String constructionType;
  final String plinthAreaGF;
  final String replacementRateGF;
  final String heightGF;
  final String ageGF;
  final String plinthAreaFF;
  final String replacementRateFF;
  final String heightFF;
  final String ageFF;
  final String plinthAreaSF;
  final String replacementRateSF;
  final String heightSF;
  final String ageSF;
  final String plinthAreaTF;
  final String replacementRateTF;
  final String heightTF;
  final String ageTF;
  final String buildingCategory;
  final String exteriorCondition;
  final String interiorCondition;
  final String foundationAndBasement;
  final String rccWorks;
  final String wallDetails;
  final String flooring;
  final String joinery;
  final String windows;
  final String roofing;
  final String landMarketRate;
  final String buildingUnitRate;
  final String classificationArea1;
  final String classificationArea2;
  final String propertyLandmark;
  final String roadDetails;
  final String mainJunction;
  final String nearbyInstitutions;
  final String nearbyTown;
  final String photos;
  final String remarks;

  Valuation({
    required this.id,
    required this.reportName,
    required this.dateOfInspection,
    required this.status,
    required this.bankDetails,
    required this.ownerDetails,
    required this.propertyPossessionAddress,
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
    required this.landCategory,
    required this.eastActual,
    required this.eastDeed,
    required this.southActual,
    required this.southDeed,
    required this.westActual,
    required this.westDeed,
    required this.northActual,
    required this.northDeed,
    required this.legalReportReference,
    required this.buildingApprovalReference,
    required this.deedRegDetails,
    required this.possessionCertificateDetails,
    required this.locationSketchDetails,
    required this.propertyTaxCertificateDetails,
    required this.buildingTaxCertificateDetails,
    required this.latitude,
    required this.longitude,
    required this.encumbranceReference,
    required this.topographyAndShape,
    required this.houseNumber,
    required this.panchayath,
    required this.electricityConsumerNo,
    required this.ksebDivision,
    required this.yearOfConstruction,
    required this.qualityOfConstruction,
    required this.buildingType,
    required this.constructionType,
    required this.plinthAreaGF,
    required this.replacementRateGF,
    required this.heightGF,
    required this.ageGF,
    required this.plinthAreaFF,
    required this.replacementRateFF,
    required this.heightFF,
    required this.ageFF,
    required this.plinthAreaSF,
    required this.replacementRateSF,
    required this.heightSF,
    required this.ageSF,
    required this.plinthAreaTF,
    required this.replacementRateTF,
    required this.heightTF,
    required this.ageTF,
    required this.buildingCategory,
    required this.exteriorCondition,
    required this.interiorCondition,
    required this.foundationAndBasement,
    required this.rccWorks,
    required this.wallDetails,
    required this.flooring,
    required this.joinery,
    required this.windows,
    required this.roofing,
    required this.landMarketRate,
    required this.buildingUnitRate,
    required this.classificationArea1,
    required this.classificationArea2,
    required this.propertyLandmark,
    required this.roadDetails,
    required this.mainJunction,
    required this.nearbyInstitutions,
    required this.nearbyTown,
    required this.photos,
    required this.remarks,
  });

  static const String ID = "id";
  static const String REPORT_NAME = "Report Name";
  static const String DATE_OF_INSPECTION = "Date of Inspection";
  static const String STATUS = "Status";
  static const String BANK_BRANCH_VALUATION_TEAM_DETAILS = "Bank/ Branch/ Valuation Team Details";
  static const String NAME_OF_THE_OWNERS_AND_ADDRESSES_WITH_PHONE_NO = "Name of the owner(s) and addresses with Phone No.";
  static const String PROPERTY_POSSESSION_NAMEPOSTAL_ADDRESS = "Property Possession Name/Postal Address`";
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
  static const String LAND_CATEGORY = "Land Category";
  static const String EAST_ACTUALS = "East - Actuals";
  static const String EAST_AS_PER_DEED = "East - As per Deed";
  static const String SOUTH_ACTUALS = "South - Actuals";
  static const String SOUTH_AS_PER_DEED = "South - As per Deed";
  static const String WEST_ACTUALS = "West - Actuals";
  static const String WEST_AS_PER_DEED = "West - As per Deed";
  static const String NORTH_ACTUALS = "North - Actuals";
  static const String NORTH_AS_PER_DEED = "North - As per Deed";
  static const String LEGAL_REPORT_REFERENCE = "Legal Report Reference";
  static const String BUILDING_APPROVAL_REFERENCE = "Building Approval Reference";
  static const String DEED_REG_SRO_NO_DATE = "Deed Reg. SRO No. & Date";
  static const String POCCESSION_CERTIFICATE_DETAILS = "Poccession Certificate Details";
  static const String LOCATION_SKETCH_DETAILS = "Location Sketch Details";
  static const String PROPERTY_TAX_CERTICATE_DETAILS = "Property Tax Certicate Details";
  static const String BUILDING_TAX_CERTIFICATE_DETAILS = "Building Tax Certificate Details";
  static const String LATTITUDE = "Lattitude";
  static const String LONGITUDE = "Longitude";
  static const String TANDAPPERENCUMFRANCE_REF = "Tandapper/Encumfrance Ref.";
  static const String LEVEL_OF_LAND_WITH_TOPOGRAPHICAL_CONDITIONS_SHAPE_OF_LAND = "Level of land with topographical conditions/ Shape of land";
  static const String HOUSE_NO_DOOR_NO = "House No./ Door No.";
  static const String PANCHAYATH = "Panchayath";
  static const String ELECTRICITY_CONSUMER_NO = "Electricity Consumer no.";
  static const String KSEB_DIVISION = "KSEB Division";
  static const String YEAR_OF_CONSTRUCTION = "Year of Construction";
  static const String QUALITY_OF_CONSTRUCTION = "Quality of Construction";
  static const String TYPE_OF_BUILDING = "Type of Building";
  static const String TYPE_OF_CONSTRUCTION = "Type of Construction";
  static const String PLINT_AREA_GF = "GF - Plint area";
  static const String REPLACEMENT_RATE_GF = "GF - Replacement Rate";
  static const String HEIGHT_GF = "GF - Height";
  static const String AGE_GF = "GF - Age";
  static const String PLINTH_AREA_FF = "FF - Plinth area";
  static const String REPLACEMENT_RATE_FF = "FF - Replacement Rate";
  static const String HEIGHT_FF = "FF - Height";
  static const String AGE_FF = "FF - Age";
  static const String PLINTH_AREA_SF = "SF - Plinth area";
  static const String REPLACEMENT_RATE_SF = "SF - Replacement Rate";
  static const String HEIGHT_SF = "SF - Height";
  static const String AGE_SF = "SF - Age";
  static const String PLINTH_AREA_TF = "TF - Plinth area";
  static const String REPLACEMENT_RATE_TF = "TF - Replacement Rate";
  static const String HEIGHT_TF = "TF - Height";
  static const String AGE_TF = "TF - Age";
  static const String BUILDING_TYPE = "Building Type";
  static const String CONDITION_OF_BUILDING_EXTERIOR = "Condition of Building - Exterior";
  static const String CONDITION_OF_BUILDING_INTERIOR = "Condition of Building -Interior";
  static const String FOUNDATION_BASEMENT = "Foundation & Basement";
  static const String RCC_WORLS = "RCC worls";
  static const String WALL_DETAILS = "Wall Details";
  static const String FLOORING = "Flooring";
  static const String JOINERYDOORS = "Joinery/Doors";
  static const String WINDOWS = "Windows";
  static const String WPROOF_TRUSS = "WP/Roof Truss";
  static const String PREVAILING_LAND_MARKET_RATE = "Prevailing Land Market Rate";
  static const String BUILDING_VALUATION_UNIT_RATE = "Building Valuation Unit Rate";
  static const String CLASSIFICATION_OF_AREA_1 = "Classification of area - 1";
  static const String CLASSIFICATION_OF_AREA_2 = "Classification of Area - 2";
  static const String LANDMARK_OF_THE_PROPERTY = "Landmark of the Property";
  static const String ROAD_DETAILS = "Road Details";
  static const String MAIN_JUNCTION = "Main Junction";
  static const String INSTITITUIONRELIGIOUS_GOVT_OFFICES = "Instituition/Religious/ Govt Offices";
  static const String NEARBY_TOWN = "Nearby Town";
  static const String PHOTOS = "Photos";
  static const String REMARKS = "Remarks";

  factory Valuation.fromJson(Map<String, dynamic> json) {
    return Valuation(
      id: json[ID],
      reportName: json[REPORT_NAME].toString(),
      dateOfInspection: json[DATE_OF_INSPECTION].toString(),
      status: json[STATUS].toString(),
      bankDetails: json[BANK_BRANCH_VALUATION_TEAM_DETAILS].toString(),
      ownerDetails: json[NAME_OF_THE_OWNERS_AND_ADDRESSES_WITH_PHONE_NO].toString(),
      propertyPossessionAddress: json[PROPERTY_POSSESSION_NAMEPOSTAL_ADDRESS].toString(),
      surveyNo1: json[SURVEY_NO_RE_SY_NO_1].toString(),
      area1: json[AREA_IN_ARE_1].toString(),
      surveyNo2: json[SURVEY_NO_RE_SY_NO_2].toString(),
      area2: json[AREA_IN_ARE_2].toString(),
      surveyNo3: json[SURVEY_NO_RE_SY_NO_3].toString(),
      area3: json[AREA_IN_ARE_3].toString(),
      surveyNo4: json[SURVEY_NO_RE_SY_NO_4].toString(),
      area4: json[AREA_IN_ARE_4].toString(),
      village: json[VILLAGE].toString(),
      taluk: json[TALUK].toString(),
      landCategory: json[LAND_CATEGORY].toString(),
      eastActual: json[EAST_ACTUALS].toString(),
      eastDeed: json[EAST_AS_PER_DEED].toString(),
      southActual: json[SOUTH_ACTUALS].toString(),
      southDeed: json[SOUTH_AS_PER_DEED].toString(),
      westActual: json[WEST_ACTUALS].toString(),
      westDeed: json[WEST_AS_PER_DEED].toString(),
      northActual: json[NORTH_ACTUALS].toString(),
      northDeed: json[NORTH_AS_PER_DEED].toString(),
      legalReportReference: json[LEGAL_REPORT_REFERENCE].toString(),
      buildingApprovalReference: json[BUILDING_APPROVAL_REFERENCE].toString(),
      deedRegDetails: json[DEED_REG_SRO_NO_DATE].toString(),
      possessionCertificateDetails: json[POCCESSION_CERTIFICATE_DETAILS].toString(),
      locationSketchDetails: json[LOCATION_SKETCH_DETAILS].toString(),
      propertyTaxCertificateDetails: json[PROPERTY_TAX_CERTICATE_DETAILS].toString(),
      buildingTaxCertificateDetails: json[BUILDING_TAX_CERTIFICATE_DETAILS].toString(),
      latitude: json[LATTITUDE].toString(),
      longitude: json[LONGITUDE].toString(),
      encumbranceReference: json[TANDAPPERENCUMFRANCE_REF].toString(),
      topographyAndShape: json[LEVEL_OF_LAND_WITH_TOPOGRAPHICAL_CONDITIONS_SHAPE_OF_LAND].toString(),
      houseNumber: json[HOUSE_NO_DOOR_NO].toString(),
      panchayath: json[PANCHAYATH].toString(),
      electricityConsumerNo: json[ELECTRICITY_CONSUMER_NO].toString(),
      ksebDivision: json[KSEB_DIVISION].toString(),
      yearOfConstruction: json[YEAR_OF_CONSTRUCTION].toString(),
      qualityOfConstruction: json[QUALITY_OF_CONSTRUCTION].toString(),
      buildingType: json[TYPE_OF_BUILDING].toString(),
      constructionType: json[TYPE_OF_CONSTRUCTION].toString(),
      plinthAreaGF: json[PLINT_AREA_GF].toString(),
      replacementRateGF: json[REPLACEMENT_RATE_GF].toString(),
      heightGF: json[HEIGHT_GF].toString(),
      ageGF: json[AGE_GF].toString(),
      plinthAreaFF: json[PLINTH_AREA_FF].toString(),
      replacementRateFF: json[REPLACEMENT_RATE_FF].toString(),
      heightFF: json[HEIGHT_FF].toString(),
      ageFF: json[AGE_FF].toString(),
      plinthAreaSF: json[PLINTH_AREA_SF].toString(),
      replacementRateSF: json[REPLACEMENT_RATE_SF].toString(),
      heightSF: json[HEIGHT_SF].toString(),
      ageSF: json[AGE_SF].toString(),
      plinthAreaTF: json[PLINTH_AREA_TF].toString(),
      replacementRateTF: json[REPLACEMENT_RATE_TF].toString(),
      heightTF: json[HEIGHT_TF].toString(),
      ageTF: json[AGE_TF].toString(),
      buildingCategory: json[BUILDING_TYPE].toString(),
      exteriorCondition: json[CONDITION_OF_BUILDING_EXTERIOR].toString(),
      interiorCondition: json[CONDITION_OF_BUILDING_INTERIOR].toString(),
      foundationAndBasement: json[FOUNDATION_BASEMENT].toString(),
      rccWorks: json[RCC_WORLS].toString(),
      wallDetails: json[WALL_DETAILS].toString(),
      flooring: json[FLOORING].toString(),
      joinery: json[JOINERYDOORS].toString(),
      windows: json[WINDOWS].toString(),
      roofing: json[WPROOF_TRUSS].toString(),
      landMarketRate: json[PREVAILING_LAND_MARKET_RATE].toString(),
      buildingUnitRate: json[BUILDING_VALUATION_UNIT_RATE].toString(),
      classificationArea1: json[CLASSIFICATION_OF_AREA_1].toString(),
      classificationArea2: json[CLASSIFICATION_OF_AREA_2].toString(),
      propertyLandmark: json[LANDMARK_OF_THE_PROPERTY].toString(),
      roadDetails: json[ROAD_DETAILS].toString(),
      mainJunction: json[MAIN_JUNCTION].toString(),
      nearbyInstitutions: json[INSTITITUIONRELIGIOUS_GOVT_OFFICES].toString(),
      nearbyTown: json[NEARBY_TOWN].toString(),
      photos: json[PHOTOS].toString(),
      remarks: json[REMARKS].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      REPORT_NAME: reportName,
      DATE_OF_INSPECTION: dateOfInspection,
      STATUS: status,
      BANK_BRANCH_VALUATION_TEAM_DETAILS: bankDetails,
      NAME_OF_THE_OWNERS_AND_ADDRESSES_WITH_PHONE_NO: ownerDetails,
      PROPERTY_POSSESSION_NAMEPOSTAL_ADDRESS: propertyPossessionAddress,
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
      LAND_CATEGORY: landCategory,
      EAST_ACTUALS: eastActual,
      EAST_AS_PER_DEED: eastDeed,
      SOUTH_ACTUALS: southActual,
      SOUTH_AS_PER_DEED: southDeed,
      WEST_ACTUALS: westActual,
      WEST_AS_PER_DEED: westDeed,
      NORTH_ACTUALS: northActual,
      NORTH_AS_PER_DEED: northDeed,
      LEGAL_REPORT_REFERENCE: legalReportReference,
      BUILDING_APPROVAL_REFERENCE: buildingApprovalReference,
      DEED_REG_SRO_NO_DATE: deedRegDetails,
      POCCESSION_CERTIFICATE_DETAILS: possessionCertificateDetails,
      LOCATION_SKETCH_DETAILS: locationSketchDetails,
      PROPERTY_TAX_CERTICATE_DETAILS: propertyTaxCertificateDetails,
      BUILDING_TAX_CERTIFICATE_DETAILS: buildingTaxCertificateDetails,
      LATTITUDE: latitude,
      LONGITUDE: longitude,
      TANDAPPERENCUMFRANCE_REF: encumbranceReference,
      LEVEL_OF_LAND_WITH_TOPOGRAPHICAL_CONDITIONS_SHAPE_OF_LAND: topographyAndShape,
      HOUSE_NO_DOOR_NO: houseNumber,
      PANCHAYATH: panchayath,
      ELECTRICITY_CONSUMER_NO: electricityConsumerNo,
      KSEB_DIVISION: ksebDivision,
      YEAR_OF_CONSTRUCTION: yearOfConstruction,
      QUALITY_OF_CONSTRUCTION: constructionType,
      TYPE_OF_BUILDING: buildingType,
      TYPE_OF_CONSTRUCTION: constructionType,
      PLINT_AREA_GF: plinthAreaGF,
      REPLACEMENT_RATE_GF: replacementRateGF,
      HEIGHT_GF: heightGF,
      AGE_GF: ageGF,
      PLINTH_AREA_FF: plinthAreaFF,
      REPLACEMENT_RATE_FF: replacementRateFF,
      HEIGHT_FF: heightFF,
      AGE_FF: ageFF,
      PLINTH_AREA_SF: plinthAreaSF,
      REPLACEMENT_RATE_SF: replacementRateSF,
      HEIGHT_SF: heightSF,
      AGE_SF: ageSF,
      PLINTH_AREA_TF: plinthAreaTF,
      REPLACEMENT_RATE_TF: replacementRateTF,
      HEIGHT_TF: heightTF,
      AGE_TF: ageTF,
      BUILDING_TYPE: buildingType,
      CONDITION_OF_BUILDING_EXTERIOR: exteriorCondition,
      CONDITION_OF_BUILDING_INTERIOR: interiorCondition,
      FOUNDATION_BASEMENT: foundationAndBasement,
      RCC_WORLS: rccWorks,
      WALL_DETAILS: wallDetails,
      FLOORING: flooring,
      JOINERYDOORS: joinery,
      WINDOWS: windows,
      WPROOF_TRUSS: roofing,
      PREVAILING_LAND_MARKET_RATE: landMarketRate,
      BUILDING_VALUATION_UNIT_RATE: buildingUnitRate,
      CLASSIFICATION_OF_AREA_1: classificationArea1,
      CLASSIFICATION_OF_AREA_2: classificationArea2,
      LANDMARK_OF_THE_PROPERTY: landMarketRate,
      ROAD_DETAILS: roadDetails,
      MAIN_JUNCTION: mainJunction,
      INSTITITUIONRELIGIOUS_GOVT_OFFICES: nearbyInstitutions,
      NEARBY_TOWN: nearbyTown,
      PHOTOS: photos,
      REMARKS: remarks,
    };
  }

  List<String?> toList() {
    return [
      reportName,
      dateOfInspection,
      status,
      bankDetails,
      ownerDetails,
      propertyPossessionAddress,
      surveyNo1,
      area1,
      surveyNo2,
      area2,
      surveyNo3,
      area3,
      surveyNo4,
      area4,
      village,
      taluk,
      landCategory,
      eastActual,
      eastDeed,
      southActual,
      southDeed,
      westActual,
      westDeed,
      northActual,
      northDeed,
      legalReportReference,
      buildingApprovalReference,
      deedRegDetails,
      possessionCertificateDetails,
      locationSketchDetails,
      propertyTaxCertificateDetails,
      buildingTaxCertificateDetails,
      latitude,
      longitude,
      encumbranceReference,
      topographyAndShape,
      houseNumber,
      panchayath,
      electricityConsumerNo,
      ksebDivision,
      yearOfConstruction,
      qualityOfConstruction,
      buildingType,
      constructionType,
      plinthAreaGF,
      replacementRateGF,
      heightGF,
      ageGF,
      plinthAreaFF,
      replacementRateFF,
      heightFF,
      ageFF,
      plinthAreaSF,
      replacementRateSF,
      heightSF,
      ageSF,
      plinthAreaTF,
      replacementRateTF,
      heightTF,
      ageTF,
      buildingCategory,
      exteriorCondition,
      interiorCondition,
      foundationAndBasement,
      rccWorks,
      wallDetails,
      flooring,
      joinery,
      windows,
      roofing,
      landMarketRate,
      buildingUnitRate,
      classificationArea1,
      classificationArea2,
      propertyLandmark,
      roadDetails,
      mainJunction,
      nearbyInstitutions,
      nearbyTown,
      photos,
      remarks,
    ];
  }

  static const editableFields = [
    REPORT_NAME,
    DATE_OF_INSPECTION,
    STATUS,
    BANK_BRANCH_VALUATION_TEAM_DETAILS,
    NAME_OF_THE_OWNERS_AND_ADDRESSES_WITH_PHONE_NO,
    PROPERTY_POSSESSION_NAMEPOSTAL_ADDRESS,
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
    LAND_CATEGORY,
    EAST_ACTUALS,
    EAST_AS_PER_DEED,
    SOUTH_ACTUALS,
    SOUTH_AS_PER_DEED,
    WEST_ACTUALS,
    WEST_AS_PER_DEED,
    NORTH_ACTUALS,
    NORTH_AS_PER_DEED,
    LEGAL_REPORT_REFERENCE,
    BUILDING_APPROVAL_REFERENCE,
    DEED_REG_SRO_NO_DATE,
    POCCESSION_CERTIFICATE_DETAILS,
    LOCATION_SKETCH_DETAILS,
    PROPERTY_TAX_CERTICATE_DETAILS,
    BUILDING_TAX_CERTIFICATE_DETAILS,
    LATTITUDE,
    LONGITUDE,
    TANDAPPERENCUMFRANCE_REF,
    LEVEL_OF_LAND_WITH_TOPOGRAPHICAL_CONDITIONS_SHAPE_OF_LAND,
    HOUSE_NO_DOOR_NO,
    PANCHAYATH,
    ELECTRICITY_CONSUMER_NO,
    KSEB_DIVISION,
    YEAR_OF_CONSTRUCTION,
    QUALITY_OF_CONSTRUCTION,
    TYPE_OF_BUILDING,
    TYPE_OF_CONSTRUCTION,
    PLINT_AREA_GF,
    REPLACEMENT_RATE_GF,
    HEIGHT_GF,
    AGE_GF,
    PLINTH_AREA_FF,
    REPLACEMENT_RATE_FF,
    HEIGHT_FF,
    AGE_FF,
    PLINTH_AREA_SF,
    REPLACEMENT_RATE_SF,
    HEIGHT_SF,
    AGE_SF,
    PLINTH_AREA_TF,
    REPLACEMENT_RATE_TF,
    HEIGHT_TF,
    AGE_TF,
    BUILDING_TYPE,
    CONDITION_OF_BUILDING_EXTERIOR,
    CONDITION_OF_BUILDING_INTERIOR,
    FOUNDATION_BASEMENT,
    RCC_WORLS,
    WALL_DETAILS,
    FLOORING,
    JOINERYDOORS,
    WINDOWS,
    WPROOF_TRUSS,
    PREVAILING_LAND_MARKET_RATE,
    BUILDING_VALUATION_UNIT_RATE,
    CLASSIFICATION_OF_AREA_1,
    CLASSIFICATION_OF_AREA_2,
    LANDMARK_OF_THE_PROPERTY,
    ROAD_DETAILS,
    MAIN_JUNCTION,
    INSTITITUIONRELIGIOUS_GOVT_OFFICES,
    NEARBY_TOWN,
    PHOTOS,
    REMARKS,
  ];

  static const statusOptions = [
    "In progress",
    "Completed",
    "Backlog",
  ];
}
