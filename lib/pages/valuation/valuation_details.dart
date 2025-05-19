import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/modals/valuation.dart';
import 'package:valuatorx/pages/common/button/action_button.dart';
import 'package:valuatorx/pages/common/delete_dialog.dart';
import 'package:valuatorx/pages/common/header/actions_header.dart';
import 'package:valuatorx/pages/common/header/title_header.dart';
import 'package:valuatorx/pages/common/view/table_view.dart';
import 'package:valuatorx/pages/common/view/view_tile.dart';
import 'package:valuatorx/providers/valuation_provider.dart';

class ValuationDetails extends StatefulWidget {
  final Valuation valuation;
  const ValuationDetails({super.key, required this.valuation});

  @override
  State<ValuationDetails> createState() => _ValuationDetailsState();
}

class _ValuationDetailsState extends State<ValuationDetails> with TickerProviderStateMixin {
  final List<String> tabs = ["General Details", "Land Details", "Building Details", "Notes", "Photo"];
  late TabController tabController;

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

    onEditAction() {
      provider.setSelectedItem(widget.valuation.id);
      Navigator.pushNamed(context, '/valuation/edit');
    }

    onDeleteAction() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => DeleteDialog(
              onDelete: () async {
                await provider.deleteValuation(context, widget.valuation);
              },
            ),
      );
      if (confirmed == true) {
        provider.setSelectedItem(-1);
      }
    }

    onBackAction() {
      provider.setSelectedItem(-1);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => onBackAction(),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainer,
        body: NestedScrollView(
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                TitleHeader(title: widget.valuation.reportName, onBackPressed: onBackAction),
                ActionsHeader(
                  actions: [
                    ActionButton(icon: Icons.edit_outlined, label: "Edit", onPressed: onEditAction),
                    ActionButton(icon: Icons.delete_outlined, label: "Delete", onPressed: onDeleteAction),
                    ActionButton(icon: Icons.public_rounded, label: "Generate Report", onPressed: () {}),
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
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TabBarView(
              controller: tabController,
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    spacing: 16,
                    children: [
                      ViewTile(
                        title: Valuation.DATE_OF_INSPECTION,
                        value: widget.valuation.dateOfInspection,
                        icon: Icons.calendar_today_outlined,
                      ),
                      ViewTile(
                        title: Valuation.BANK_BRANCH_VALUATION_TEAM_DETAILS,
                        value: widget.valuation.bankDetails,
                        icon: Icons.business_outlined,
                      ),
                      ViewTile(
                        title: Valuation.NAME_OF_THE_OWNERS_AND_ADDRESSES_WITH_PHONE_NO,
                        value: widget.valuation.ownerDetails,
                        icon: Icons.group_outlined,
                      ),
                      ViewTile(
                        title: Valuation.PROPERTY_POSSESSION_NAMEPOSTAL_ADDRESS,
                        value: widget.valuation.propertyPossessionAddress,
                        icon: Icons.work_outline_outlined,
                      ),
                      ViewTile(
                        title: Valuation.POCCESSION_CERTIFICATE_DETAILS,
                        value: widget.valuation.possessionCertificateDetails,
                        icon: Icons.article_outlined,
                      ),
                      ViewTile(
                        title: Valuation.DEED_REG_SRO_NO_DATE,
                        value: widget.valuation.deedRegDetails,
                        icon: Icons.assignment_ind_outlined,
                      ),
                      ViewTile(
                        title: Valuation.LEGAL_REPORT_REFERENCE,
                        value: widget.valuation.legalReportReference,
                        icon: Icons.policy_outlined,
                      ),
                      ViewTile(
                        title: Valuation.BUILDING_APPROVAL_REFERENCE,
                        value: widget.valuation.buildingApprovalReference,
                        icon: Icons.verified_user_outlined,
                      ),
                      ViewTile(
                        title: Valuation.PROPERTY_TAX_CERTICATE_DETAILS,
                        value: widget.valuation.propertyTaxCertificateDetails,
                        icon: Icons.approval_outlined,
                      ),
                      ViewTile(
                        title: Valuation.BUILDING_TAX_CERTIFICATE_DETAILS,
                        value: widget.valuation.buildingTaxCertificateDetails,
                        icon: Icons.account_balance_outlined,
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    spacing: 16,
                    children: [
                      TableViewTile(
                        title: "Property Area",
                        icon: Icons.straighten_outlined,
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
                        title: "Property Area",
                        icon: Icons.straighten_outlined,
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
                        title: Valuation.BANK_BRANCH_VALUATION_TEAM_DETAILS,
                        value: widget.valuation.bankDetails,
                        icon: Icons.business_outlined,
                      ),
                    ],
                  ),
                ),
                Center(child: Text("bar")),
                Center(child: Text("mafia")),
                Center(child: Text("fack")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
