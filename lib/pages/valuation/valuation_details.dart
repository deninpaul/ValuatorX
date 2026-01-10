import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:valuatorx/models/valuation.dart';
import 'package:valuatorx/pages/common/button/action_button.dart';
import 'package:valuatorx/pages/common/modal/delete_dialog.dart';
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
import 'package:valuatorx/utils/common.dart';

class ValuationDetails extends StatefulWidget {
  final Valuation valuation;
  final bool readOnly;
  final EdgeInsetsGeometry padding;
  const ValuationDetails({super.key, required this.valuation, this.readOnly = false, this.padding = const EdgeInsets.all(0)});

  @override
  State<ValuationDetails> createState() => _ValuationDetailsState();
}

class _ValuationDetailsState extends State<ValuationDetails> with TickerProviderStateMixin {
  final List<String> tabs = ["General Details", "Land Details", "Building Details", "Notes", "Photo"];
  final TextEditingController tagController = TextEditingController();
  final MapController mapController = MapController();
  late TabController tabController;

  bool get isDraft => widget.valuation.id.contains("draft_");
  bool get isReportGenerated => widget.valuation.reportLink.isNotEmpty;

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
    final formPadding = EdgeInsets.symmetric(vertical: 24, horizontal: isDesktop(context) ? 200 : 15);

    onEditAction({String fieldName = "", int fieldTab = 0}) {
      if (!widget.readOnly) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ValuationForm(mode: Mode.edit, focusField: fieldName, focusTabIndex: fieldTab)),
        );
      }
    }

    onResumeAction() {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ValuationForm(mode: Mode.edit, isDraft: true)));
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

    onDuplicateAction() {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ValuationForm(mode: Mode.create, template: widget.valuation)));
      provider.setSelectedItem("");
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
                  title: widget.valuation.title,
                  expandedHeight: 124,
                  onBackPressed: onBackAction,
                  readOnly: widget.readOnly,
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
                if (!widget.readOnly)
                  ActionsHeader(
                    actions: [
                      ActionButton(
                        icon: isDraft ? Icons.arrow_forward : Icons.edit_outlined,
                        label: isDraft ? "Resume" : "Edit",
                        onPressed: isDraft ? onResumeAction : onEditAction,
                      ),
                      ActionButton(icon: Icons.delete_outlined, label: !isDraft ? "Delete" : "Delete Draft", onPressed: onDeleteAction),
                      if (!isDraft)
                        ActionButton(
                          icon: isReportGenerated ? Icons.launch : Icons.note_add_outlined,
                          label: isReportGenerated ? "Open in\nExcel" : "Generate\nExcel",
                          onPressed: isReportGenerated ? onOpenReport : onGenerateReport,
                        ),
                      if (!isDraft) ActionButton(icon: Icons.copy, label: "Duplicate", onPressed: onDuplicateAction),
                    ],
                  ),
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: 48,
                  backgroundColor: colorScheme.surfaceContainer,
                  surfaceTintColor: colorScheme.surfaceContainer,
                  automaticallyImplyLeading: false,
                  primary: false,
                  title: Padding(
                    padding: widget.padding,
                    child: TabBar(
                      controller: tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.center,
                      padding: EdgeInsets.only(top: 0),
                      tabs: tabs.map((tab) => Tab(text: tab)).toList(),
                    ),
                  ),
                ),
              ],
          body: Padding(
            padding: widget.padding,
            child: TabBarView(
              controller: tabController,
              children: [
                SingleChildScrollView(
                  padding: formPadding,
                  child: Column(
                    spacing: 13,
                    children: [
                      if (!isMobile(context))
                        IntrinsicHeight(
                          child: Row(
                            spacing: 15,
                            children: [
                              Expanded(
                                child: ViewTile(
                                  title: Valuation.REPORT_REFERENCE,
                                  value: widget.valuation.reportReference,
                                  icon: Icons.numbers_outlined,
                                  onPressed: onEditAction,
                                  tabIndex: 0,
                                ),
                              ),
                              Expanded(
                                child: ViewTile(
                                  title: Valuation.DATE_OF_INSPECTION,
                                  value: widget.valuation.dateOfInspection,
                                  icon: Icons.calendar_today_outlined,
                                  onPressed: onEditAction,
                                  tabIndex: 0,
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        ViewTile(
                          title: Valuation.REPORT_REFERENCE,
                          value: widget.valuation.reportReference,
                          icon: Icons.grid_3x3_outlined,
                          onPressed: onEditAction,
                          tabIndex: 0,
                        ),
                        ViewTile(
                          title: Valuation.DATE_OF_INSPECTION,
                          value: widget.valuation.dateOfInspection,
                          icon: Icons.calendar_today_outlined,
                          onPressed: onEditAction,
                          tabIndex: 0,
                        ),
                      ],
                      ViewTile(
                        title: Valuation.BANK_DETAIL,
                        value: widget.valuation.bankDetails,
                        icon: Icons.account_balance_outlined,
                        onPressed: onEditAction,
                        tabIndex: 0,
                      ),
                      ViewTile(
                        title: Valuation.TYPE_OF_LOAN,
                        value: widget.valuation.typeOfLoan,
                        icon: Icons.paid_outlined,
                        onPressed: onEditAction,
                        tabIndex: 0,
                      ),
                      ViewTile(
                        title: "File Allocation Details",
                        value: widget.valuation.fileAllocationDetail,
                        icon: Icons.business_outlined,
                        onPressed: onEditAction,
                        tabIndex: 0,
                      ),
                      Divider(),
                      ViewTile(
                        title: Valuation.MORTGAGOR_DETAIL,
                        value: widget.valuation.mortgagorDetail,
                        icon: Icons.group_outlined,
                        onPressed: onEditAction,
                        tabIndex: 0,
                      ),
                      ViewTile(
                        title: Valuation.MORTGAGOR_MOBILE,
                        value: widget.valuation.mortgagorNumber,
                        icon: Icons.dialpad,
                        onPressed: onEditAction,
                        tabIndex: 0,
                      ),
                      ViewTile(
                        title: Valuation.DEED_OWNER_DETAIL,
                        value: widget.valuation.deedOwnerDetail,
                        icon: Icons.inbox_outlined,
                        onPressed: onEditAction,
                        tabIndex: 0,
                      ),
                      ViewTile(
                        title: Valuation.LEGAL_REPORT_REFERENCE,
                        value: widget.valuation.legalReportDetail,
                        icon: Icons.policy_outlined,
                        onPressed: onEditAction,
                        tabIndex: 0,
                      ),
                      ViewTile(
                        title: Valuation.DEED_DOCUMENT_DETAILS,
                        value: widget.valuation.deedDocumentDetails,
                        icon: Icons.assignment_ind_outlined,
                        onPressed: onEditAction,
                        tabIndex: 0,
                      ),
                      ViewTile(
                        title: Valuation.LAND_CATEGORY,
                        value: widget.valuation.bankDetails,
                        icon: Icons.landscape_outlined,
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
                        title: Valuation.LOCATION_SKETCH_DETAILS,
                        value: widget.valuation.locationSketchDetails,
                        icon: Icons.edit_location_alt_outlined,
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
                        value: widget.valuation.buildingTaxDetails,
                        icon: Icons.account_balance_outlined,
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
                    ],
                  ),
                ),
                SingleChildScrollView(
                  padding: formPadding,
                  child: Column(
                    spacing: 13,
                    children: [
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
                      Divider(),
                      if (!isMobile(context))
                        IntrinsicHeight(
                          child: Row(
                            spacing: 15,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                child: ViewTile(
                                  title: Valuation.TALUK,
                                  value: widget.valuation.taluk,
                                  onPressed: onEditAction,
                                  tabIndex: 1,
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        ViewTile(
                          title: Valuation.VILLAGE,
                          value: widget.valuation.village,
                          icon: Icons.cottage_outlined,
                          onPressed: onEditAction,
                          tabIndex: 1,
                        ),
                        ViewTile(
                          title: Valuation.TALUK,
                          value: widget.valuation.taluk,
                          icon: Icons.holiday_village_outlined,
                          onPressed: onEditAction,
                          tabIndex: 1,
                        ),
                      ],
                      if (!isMobile(context))
                        IntrinsicHeight(
                          child: Row(
                            spacing: 15,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  title: Valuation.MAIN_CENTER,
                                  value: widget.valuation.mainCenter,
                                  onPressed: onEditAction,
                                  tabIndex: 1,
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        ViewTile(
                          title: Valuation.PANCHAYATH,
                          value: widget.valuation.panchayath,
                          icon: Icons.account_balance_outlined,
                          onPressed: onEditAction,
                          tabIndex: 1,
                        ),
                        ViewTile(
                          title: Valuation.MAIN_CENTER,
                          value: widget.valuation.mainCenter,
                          icon: Icons.hub_outlined,
                          onPressed: onEditAction,
                          tabIndex: 1,
                        ),
                      ],
                      ViewTile(
                        title: Valuation.NEARBY_TOWN,
                        value: widget.valuation.nearbyTown,
                        icon: Icons.near_me_outlined,
                        onPressed: onEditAction,
                        tabIndex: 1,
                      ),
                      ViewTile(
                        title: Valuation.LANDMARK_OF_THE_PROPERTY,
                        value: widget.valuation.propertyLandmark,
                        icon: Icons.flag_outlined,
                        onPressed: onEditAction,
                        tabIndex: 1,
                      ),
                      Divider(),
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
                        title: Valuation.ROAD_DETAILS,
                        value: widget.valuation.roadDetails,
                        icon: Icons.route_outlined,
                        onPressed: onEditAction,
                        tabIndex: 1,
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  padding: formPadding,
                  child: Column(
                    spacing: 13,
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
                      ViewTile(
                        title: Valuation.BUILDING_DESCRIPTION,
                        value: widget.valuation.buildingDescription,
                        onPressed: onEditAction,
                        icon: Icons.description_outlined,
                        tabIndex: 2,
                      ),
                      ViewTile(
                        title: Valuation.YEAR_OF_CONSTRUCTION,
                        value: widget.valuation.yearOfConstruction,
                        onPressed: onEditAction,
                        icon: Icons.event_outlined,
                        tabIndex: 2,
                      ),
                      if (!isMobile(context))
                        IntrinsicHeight(
                          child: Row(
                            spacing: 15,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  title: Valuation.TYPE_OF_BUILDING,
                                  value: widget.valuation.buildingType,
                                  onPressed: onEditAction,
                                  tabIndex: 2,
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        ViewTile(
                          title: Valuation.TYPE_OF_CONSTRUCTION,
                          value: widget.valuation.constructionType,
                          icon: Icons.calendar_month_outlined,
                          onPressed: onEditAction,
                          tabIndex: 2,
                        ),
                        ViewTile(
                          title: Valuation.TYPE_OF_BUILDING,
                          value: widget.valuation.buildingType,
                          icon: Icons.domain_outlined,
                          onPressed: onEditAction,
                          tabIndex: 2,
                        ),
                      ],
                      if (!isMobile(context))
                        IntrinsicHeight(
                          child: Row(
                            spacing: 15,
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
                        )
                      else ...[
                        ViewTile(
                          title: Valuation.CONDITION_OF_BUILDING_EXTERIOR,
                          value: widget.valuation.exteriorCondition,
                          icon: Icons.verified_outlined,
                          onPressed: onEditAction,
                          tabIndex: 2,
                        ),
                        ViewTile(
                          title: Valuation.CONDITION_OF_BUILDING_INTERIOR,
                          value: widget.valuation.interiorCondition,
                          icon: Icons.verified_outlined,
                          onPressed: onEditAction,
                          tabIndex: 2,
                        ),
                      ],
                      Divider(),
                      ViewTile(
                        title: Valuation.FOUNDATION_BASEMENT,
                        value: widget.valuation.foundationAndBasement,
                        icon: Icons.foundation_outlined,
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
                        title: Valuation.ROOFING,
                        value: widget.valuation.roofing,
                        icon: Icons.gite_outlined,
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
                        title: Valuation.CEILING_FINISH,
                        value: widget.valuation.ceilingFinish,
                        icon: Icons.ac_unit_outlined,
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
                        title: Valuation.DOORS,
                        value: widget.valuation.doors,
                        icon: Icons.sensor_door_outlined,
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
                      Divider(),
                      TableViewTile(
                        title: "Floor measurements",
                        icon: Icons.straighten_outlined,
                        onPressed: onEditAction,
                        tabIndex: 2,
                        values: [
                          [widget.valuation.plinthAreaGF, widget.valuation.replacementRateGF],
                          [widget.valuation.plinthAreaFF, widget.valuation.replacementRateFF],
                          [widget.valuation.plinthAreaSF, widget.valuation.replacementRateSF],
                          [widget.valuation.plinthAreaTF, widget.valuation.replacementRateTF],
                        ],
                        fieldNames: [
                          [Valuation.PLINT_AREA_GF, Valuation.REPLACEMENT_RATE_GF],
                          [Valuation.PLINTH_AREA_FF, Valuation.REPLACEMENT_RATE_FF],
                          [Valuation.PLINTH_AREA_SF, Valuation.REPLACEMENT_RATE_SF],
                          [Valuation.PLINTH_AREA_TF, Valuation.REPLACEMENT_RATE_TF],
                        ],
                      ),
                      ViewTile(
                        title: Valuation.PREVAILING_AREA_RATE_AT_CENTER,
                        value: widget.valuation.areaRateCenter,
                        icon: Icons.paid_outlined,
                        onPressed: onEditAction,
                        tabIndex: 2,
                      ),
                      ViewTile(
                        title: Valuation.PROPERTY_AREA_RATE,
                        value: widget.valuation.propertyAreaRate,
                        icon: Icons.sell_outlined,
                        onPressed: onEditAction,
                        tabIndex: 2,
                      ),
                      ViewTile(
                        title: Valuation.BUILDING_REPLACEMENT_RATE,
                        value: widget.valuation.buildingReplacementRate,
                        icon: Icons.toll_outlined,
                        onPressed: onEditAction,
                        tabIndex: 2,
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  padding: formPadding,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          MediaQuery.of(context).size.height - 440 < 0
                              ? MediaQuery.of(context).size.height - 200
                              : MediaQuery.of(context).size.height - 400,
                    ),
                    child: NotesViewer(title: Valuation.REMARKS, value: widget.valuation.remarks, onPressed: onEditAction, tabIndex: 3),
                  ),
                ),
                Padding(
                  padding: formPadding,
                  child: ImagePickerField(
                    editMode: false,
                    readOnly: widget.readOnly,
                    value: widget.valuation.photos,
                    onEditAction: () => onEditAction(fieldTab: 4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
