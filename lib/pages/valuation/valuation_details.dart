import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:valuatorx/modals/valuation.dart';
import 'package:valuatorx/pages/common/button/action_button.dart';
import 'package:valuatorx/pages/common/delete_dialog.dart';
import 'package:valuatorx/pages/common/field/tag.dart';
import 'package:valuatorx/pages/common/header/actions_header.dart';
import 'package:valuatorx/pages/common/header/title_header.dart';
import 'package:valuatorx/pages/common/image/image_picker.dart';
import 'package:valuatorx/pages/common/view/location_view.dart';
import 'package:valuatorx/pages/common/view/notes_view.dart';
import 'package:valuatorx/pages/common/view/table_view.dart';
import 'package:valuatorx/pages/common/view/view_tile.dart';
import 'package:valuatorx/pages/valuation/components/generate_dialog.dart';
import 'package:valuatorx/pages/valuation/valuation_form.dart';
import 'package:valuatorx/providers/valuation_provider.dart';

class ValuationDetails extends StatefulWidget {
  final Valuation valuation;
  const ValuationDetails({super.key, required this.valuation});

  @override
  State<ValuationDetails> createState() => _ValuationDetailsState();
}

class _ValuationDetailsState extends State<ValuationDetails> with TickerProviderStateMixin {
  final List<String> tabs = ["General Details", "Land Details", "Building Details", "Notes", "Photo"];
  final TextEditingController tagController = TextEditingController();
  final MapController mapController = MapController();
  late TabController tabController;

  bool get isDraft => widget.valuation.id.contains("draft_");

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = Provider.of<ValuationProvider>(context);

    onEditAction({String fieldName = "", int fieldTab = 0}) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ValuationForm(editMode: true, focusField: fieldName, focusTabIndex: fieldTab)),
      );
    }

    onGenerateReport() async {
      await showDialog<bool>(context: context, barrierDismissible: false, builder: (ctx) => GenerateDialog(valuation: widget.valuation));
    }

    onOpenReport() async {
      final url = Uri.parse(widget.valuation.reportLink);
      if (!await launchUrl(url)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open report in excel')));
      }
    }

    onDeleteAction() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => DeleteDialog(
              onDelete: () async {
                if (isDraft) {
                  await provider.deleteDraft(widget.valuation.id);
                } else {
                  await provider.deleteValuation(context, widget.valuation);
                }
              },
            ),
      );
      if (confirmed == true) {
        provider.setSelectedItem("");
      }
    }

    onBackAction() {
      provider.setSelectedItem("");
    }

    updateTagAction(String newStatus) async {
      widget.valuation.status = newStatus;
      await provider.updateValuation(context, widget.valuation);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => onBackAction(),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainer,
        body: NestedScrollView(
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                TitleHeader(
                  title: widget.valuation.reportName,
                  expandedHeight: 124,
                  onBackPressed: onBackAction,
                  actions: [
                    Tag(
                      text: widget.valuation.status,
                      isEditable: true,
                      onStatusChange: updateTagAction,
                      isLoading: provider.isCreating,
                      disabled: isDraft,
                    ),
                  ],
                ),
                ActionsHeader(
                  actions: [
                    ActionButton(
                      icon: !isDraft ? Icons.edit_outlined : Icons.arrow_forward,
                      label: !isDraft ? "Edit" : "Resume",
                      onPressed: onEditAction,
                    ),
                    ActionButton(icon: Icons.delete_outlined, label: !isDraft ? "Delete" : "Delete Draft", onPressed: onDeleteAction),
                    if (!isDraft)
                      widget.valuation.reportLink.isEmpty
                          ? ActionButton(icon: Icons.note_add_outlined, label: "Generate\nReport", onPressed: onGenerateReport)
                          : ActionButton(icon: Icons.launch, label: "Open\nReport", onPressed: onOpenReport),
                  ],
                ),
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: 68,
                  backgroundColor: colorScheme.surfaceContainer,
                  surfaceTintColor: colorScheme.surfaceContainer,
                  title: TabBar(
                    controller: tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.center,
                    padding: EdgeInsets.only(top: 12),
                    tabs: tabs.map((tab) => Tab(text: tab)).toList(),
                  ),
                ),
              ],
          body: TabBarView(
            controller: tabController,
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: Column(
                  spacing: 16,
                  children: [
                    ViewTile(
                      title: Valuation.DATE_OF_INSPECTION,
                      value: widget.valuation.dateOfInspection,
                      icon: Icons.calendar_today_outlined,
                      onPressed: onEditAction,
                      tabIndex: 0,
                    ),
                    ViewTile(
                      title: Valuation.BANK_BRANCH_VALUATION_TEAM_DETAILS,
                      value: widget.valuation.bankDetails,
                      icon: Icons.business_outlined,
                      onPressed: onEditAction,
                      tabIndex: 0,
                    ),
                    ViewTile(
                      title: Valuation.NAME_OF_THE_OWNERS_AND_ADDRESSES_WITH_PHONE_NO,
                      value: widget.valuation.ownerDetails,
                      icon: Icons.group_outlined,
                      onPressed: onEditAction,
                      tabIndex: 0,
                    ),
                    ViewTile(
                      title: Valuation.PROPERTY_POSSESSION_NAMEPOSTAL_ADDRESS,
                      value: widget.valuation.propertyPossessionAddress,
                      icon: Icons.inbox_outlined,
                      onPressed: onEditAction,
                      tabIndex: 0,
                    ),
                    ViewTile(
                      title: Valuation.POCCESSION_CERTIFICATE_DETAILS,
                      value: widget.valuation.possessionCertificateDetails,
                      icon: Icons.article_outlined,
                      onPressed: onEditAction,
                      tabIndex: 0,
                    ),
                    ViewTile(
                      title: Valuation.DEED_REG_SRO_NO_DATE,
                      value: widget.valuation.deedRegDetails,
                      icon: Icons.assignment_ind_outlined,
                      onPressed: onEditAction,
                      tabIndex: 0,
                    ),
                    ViewTile(
                      title: Valuation.LEGAL_REPORT_REFERENCE,
                      value: widget.valuation.legalReportReference,
                      icon: Icons.policy_outlined,
                      onPressed: onEditAction,
                      tabIndex: 0,
                    ),
                    ViewTile(
                      title: Valuation.BUILDING_APPROVAL_REFERENCE,
                      value: widget.valuation.buildingApprovalReference,
                      icon: Icons.verified_user_outlined,
                      onPressed: onEditAction,
                      tabIndex: 0,
                    ),
                    ViewTile(
                      title: Valuation.PROPERTY_TAX_CERTICATE_DETAILS,
                      value: widget.valuation.propertyTaxCertificateDetails,
                      icon: Icons.approval_outlined,
                      onPressed: onEditAction,
                      tabIndex: 0,
                    ),
                    ViewTile(
                      title: Valuation.BUILDING_TAX_CERTIFICATE_DETAILS,
                      value: widget.valuation.buildingTaxCertificateDetails,
                      icon: Icons.account_balance_outlined,
                      onPressed: onEditAction,
                      tabIndex: 0,
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: Column(
                  spacing: 16,
                  children: [
                    Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: ViewTile(
                            title: Valuation.VILLAGE,
                            value: widget.valuation.village,
                            icon: Icons.cottage_outlined,
                            onPressed: onEditAction,
                            tabIndex: 1,
                          ),
                        ),
                        Expanded(
                          child: ViewTile(title: Valuation.TALUK, value: widget.valuation.taluk, onPressed: onEditAction, tabIndex: 1),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: ViewTile(
                            title: Valuation.PANCHAYATH,
                            value: widget.valuation.panchayath,
                            icon: Icons.account_balance_outlined,
                            onPressed: onEditAction,
                            tabIndex: 1,
                          ),
                        ),
                        Expanded(
                          child: ViewTile(
                            title: Valuation.KSEB_DIVISION,
                            value: widget.valuation.ksebDivision,
                            onPressed: onEditAction,
                            tabIndex: 1,
                          ),
                        ),
                      ],
                    ),
                    LocationViewTile(
                      mapController: mapController,
                      latitude: widget.valuation.latitude,
                      longitude: widget.valuation.longitude,
                      onPressed: onEditAction,
                      icon: Icons.gps_fixed_outlined,
                      tabIndex: 1,
                      label: "",
                    ),
                    TableViewTile(
                      title: "Property Area",
                      icon: Icons.straighten_outlined,
                      onPressed: onEditAction,
                      tabIndex: 1,
                      minRows: 2,
                      values: [
                        [widget.valuation.surveyNo1, widget.valuation.area1],
                        [widget.valuation.surveyNo2, widget.valuation.area2],
                        [widget.valuation.surveyNo3, widget.valuation.area3],
                        [widget.valuation.surveyNo4, widget.valuation.area4],
                      ],
                      fieldNames: [
                        ["Survey No./ Re. Sy. No.", "Area (in Are)"],
                        ["Survey No./ Re. Sy. No.", "Area (in Are)"],
                        ["Survey No./ Re. Sy. No.", "Area (in Are)"],
                        ["Survey No./ Re. Sy. No.", "Area (in Are)"],
                      ],
                    ),
                    TableViewTile(
                      title: "Property Boundaries",
                      icon: Icons.aspect_ratio_outlined,
                      onPressed: onEditAction,
                      tabIndex: 1,
                      values: [
                        [widget.valuation.eastActual, widget.valuation.eastDeed],
                        [widget.valuation.southActual, widget.valuation.southDeed],
                        [widget.valuation.westActual, widget.valuation.westDeed],
                        [widget.valuation.northActual, widget.valuation.northDeed],
                      ],
                      fieldNames: [
                        [Valuation.EAST_ACTUALS, Valuation.EAST_AS_PER_DEED],
                        [Valuation.SOUTH_ACTUALS, Valuation.SOUTH_AS_PER_DEED],
                        [Valuation.WEST_ACTUALS, Valuation.WEST_AS_PER_DEED],
                        [Valuation.NORTH_ACTUALS, Valuation.NORTH_AS_PER_DEED],
                      ],
                    ),
                    ViewTile(
                      title: Valuation.LANDMARK_OF_THE_PROPERTY,
                      value: widget.valuation.propertyLandmark,
                      icon: Icons.flag_outlined,
                      onPressed: onEditAction,
                      tabIndex: 1,
                    ),
                    TableViewTile(
                      title: "Feasability of Civic amenities",
                      icon: Icons.holiday_village_outlined,
                      values: [
                        [widget.valuation.roadDetails],
                        [widget.valuation.mainJunction],
                        [widget.valuation.nearbyInstitutions],
                        [widget.valuation.nearbyTown],
                      ],
                      fieldNames: [
                        [Valuation.ROAD_DETAILS],
                        [Valuation.MAIN_JUNCTION],
                        [Valuation.INSTITITUIONRELIGIOUS_GOVT_OFFICES],
                        [Valuation.NEARBY_TOWN],
                      ],
                      minRows: 4,
                      onPressed: onEditAction,
                      tabIndex: 1,
                    ),
                    ViewTile(
                      title: Valuation.LOCATION_SKETCH_DETAILS,
                      value: widget.valuation.locationSketchDetails,
                      icon: Icons.edit_location_alt_outlined,
                      onPressed: onEditAction,
                      tabIndex: 1,
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: Column(
                  spacing: 16,
                  children: [
                    ViewTile(
                      title: Valuation.HOUSE_NO_DOOR_NO,
                      value: widget.valuation.houseNumber,
                      icon: Icons.sensor_door_outlined,
                      onPressed: onEditAction,
                      tabIndex: 2,
                    ),
                    ViewTile(
                      title: Valuation.ELECTRICITY_CONSUMER_NO,
                      value: widget.valuation.electricityConsumerNo,
                      icon: Icons.lightbulb_outline,
                      onPressed: onEditAction,
                      tabIndex: 2,
                    ),
                    Row(
                      spacing: 16,
                      children: [
                        Flexible(
                          flex: 6,
                          child: ViewTile(
                            title: Valuation.TYPE_OF_BUILDING,
                            value: widget.valuation.buildingType,
                            icon: Icons.domain_outlined,
                            onPressed: onEditAction,
                            tabIndex: 2,
                          ),
                        ),
                        Flexible(
                          flex: 5,
                          child: ViewTile(
                            title: Valuation.YEAR_OF_CONSTRUCTION,
                            value: widget.valuation.yearOfConstruction,
                            onPressed: onEditAction,
                            tabIndex: 2,
                          ),
                        ),
                      ],
                    ),
                    TableViewTile(
                      title: "Floor measurements",
                      icon: Icons.straighten_outlined,
                      onPressed: onEditAction,
                      tabIndex: 2,
                      values: [
                        [
                          widget.valuation.plinthAreaGF,
                          widget.valuation.heightGF,
                          widget.valuation.ageGF,
                          widget.valuation.replacementRateGF,
                        ],
                        [
                          widget.valuation.plinthAreaFF,
                          widget.valuation.heightFF,
                          widget.valuation.ageFF,
                          widget.valuation.replacementRateFF,
                        ],
                        [
                          widget.valuation.plinthAreaSF,
                          widget.valuation.heightSF,
                          widget.valuation.ageSF,
                          widget.valuation.replacementRateSF,
                        ],
                        [
                          widget.valuation.plinthAreaTF,
                          widget.valuation.heightTF,
                          widget.valuation.ageTF,
                          widget.valuation.replacementRateTF,
                        ],
                      ],
                      fieldNames: [
                        [Valuation.PLINT_AREA_GF, Valuation.HEIGHT_GF, Valuation.AGE_GF, Valuation.REPLACEMENT_RATE_GF],
                        [Valuation.PLINTH_AREA_FF, Valuation.HEIGHT_FF, Valuation.AGE_FF, Valuation.REPLACEMENT_RATE_FF],
                        [Valuation.PLINTH_AREA_SF, Valuation.HEIGHT_SF, Valuation.AGE_SF, Valuation.REPLACEMENT_RATE_SF],
                        [Valuation.PLINTH_AREA_TF, Valuation.HEIGHT_TF, Valuation.AGE_TF, Valuation.REPLACEMENT_RATE_TF],
                      ],
                    ),
                    Row(
                      spacing: 16,
                      children: [
                        Flexible(
                          flex: 6,
                          child: ViewTile(
                            title: Valuation.TYPE_OF_CONSTRUCTION,
                            value: widget.valuation.constructionType,
                            icon: Icons.factory_outlined,
                            onPressed: onEditAction,
                            tabIndex: 2,
                          ),
                        ),
                        Flexible(
                          flex: 5,
                          child: ViewTile(
                            title: Valuation.QUALITY_OF_CONSTRUCTION,
                            value: widget.valuation.qualityOfConstruction,
                            onPressed: onEditAction,
                            tabIndex: 2,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 16,
                      children: [
                        Flexible(
                          flex: 6,
                          child: ViewTile(
                            title: Valuation.CONDITION_OF_BUILDING_EXTERIOR,
                            value: widget.valuation.exteriorCondition,
                            icon: Icons.verified_outlined,
                            onPressed: onEditAction,
                            tabIndex: 2,
                          ),
                        ),
                        Flexible(
                          flex: 5,
                          child: ViewTile(
                            title: Valuation.CONDITION_OF_BUILDING_INTERIOR,
                            value: widget.valuation.interiorCondition,
                            onPressed: onEditAction,
                            tabIndex: 2,
                          ),
                        ),
                      ],
                    ),
                    ViewTile(
                      title: Valuation.FOUNDATION_BASEMENT,
                      value: widget.valuation.foundationAndBasement,
                      icon: Icons.foundation_outlined,
                      onPressed: onEditAction,
                      tabIndex: 2,
                    ),
                    ViewTile(
                      title: Valuation.RCC_WORKS,
                      value: widget.valuation.rccWorks,
                      icon: Icons.grid_3x3_outlined,
                      onPressed: onEditAction,
                      tabIndex: 2,
                    ),
                    ViewTile(
                      title: Valuation.WALL_DETAILS,
                      value: widget.valuation.wallDetails,
                      icon: Icons.width_full_outlined,
                      onPressed: onEditAction,
                      tabIndex: 2,
                    ),
                    ViewTile(
                      title: Valuation.FLOORING,
                      value: widget.valuation.flooring,
                      icon: Icons.dashboard_outlined,
                      onPressed: onEditAction,
                      tabIndex: 2,
                    ),
                    ViewTile(
                      title: Valuation.JOINERYDOORS,
                      value: widget.valuation.joinery,
                      icon: Icons.sensor_door_outlined,
                      onPressed: onEditAction,
                      tabIndex: 2,
                    ),
                    ViewTile(
                      title: Valuation.WINDOWS,
                      value: widget.valuation.windows,
                      icon: Icons.window_outlined,
                      onPressed: onEditAction,
                      tabIndex: 2,
                    ),
                    ViewTile(
                      title: Valuation.WPROOF_TRUSS,
                      value: widget.valuation.roofing,
                      icon: Icons.gite_outlined,
                      onPressed: onEditAction,
                      tabIndex: 2,
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 440),
                  child: NotesViewer(title: Valuation.REMARKS, value: widget.valuation.remarks, onPressed: onEditAction, tabIndex: 3),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: ImagePickerField(editMode: false, value: widget.valuation.photos, onEditAction: () => onEditAction(fieldTab: 4)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
