import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/modals/valuation.dart';
import 'package:valuatorx/pages/common/field/area_field.dart';
import 'package:valuatorx/pages/common/field/basic_field.dart';
import 'package:valuatorx/pages/common/field/table_field.dart';
import 'package:valuatorx/pages/common/button/save_button.dart';
import 'package:valuatorx/providers/valuation_provider.dart';
import 'package:valuatorx/utils/common_utils.dart';

class ValuationForm extends StatefulWidget {
  final bool editMode;
  const ValuationForm({super.key, this.editMode = false});

  @override
  State<ValuationForm> createState() => _ValuationFormState();
}

class _ValuationFormState extends State<ValuationForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {};
  final List<String> fieldKeys = Valuation.editableFields;
  final List<String> tabs = ["General Details", "Land Details", "Building Details", "Notes", "Photo"];
  late TabController _tabController;
  bool ready = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    for (final key in fieldKeys) {
      controllers[key] = TextEditingController();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      populateForm();
    });
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    _tabController.dispose();
    super.dispose();
  }

  populateForm() async {
    final provider = Provider.of<ValuationProvider>(context, listen: false);
    if (widget.editMode) {
      final valuationToEdit = provider.getSelectedValuation();
      final values = valuationToEdit.toJson();
      for (final key in fieldKeys) {
        controllers[key]!.text = values[key];
      }
    }
    setState(() => ready = true);
  }

  submitForm() async {
    // final provider = Provider.of<LandRateProvider>(context, listen: false);
    // final id = widget.editMode ? provider.getSelectedLandRate().id : provider.generateIndex();
    // final values = {for (final key in fieldKeys) key: controllers[key]!.text.trim(), "id": id};
    // final LandRate newLandRate = LandRate.fromJson(values);
    // if (widget.editMode) {
    //   await provider.updateLandRate(context, newLandRate);
    // } else {
    //   await provider.addLandRate(context, newLandRate);
    // }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final modeName = widget.editMode ? "Edit" : "New";
    final formPadding = EdgeInsets.symmetric(horizontal: isMobile ? 24 : 48, vertical: 32);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text("$modeName Valuation Report", style: headerTheme),
        leading: IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        actions: [
          SaveButton(formKey: _formKey, onSubmit: () {}, enabled: ready),
          PopupMenuButton(
            offset: const Offset(0, 48),
            itemBuilder: (ctx) => [PopupMenuItem(child: Text("Clear form"))],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            SingleChildScrollView(
              padding: formPadding,
              child: Column(
                spacing: 24,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BasicField(
                    name: Valuation.REPORT_NAME,
                    controller: controllers[Valuation.REPORT_NAME]!,
                    icon: Icons.person_outline,
                  ),
                  BasicField(
                    name: Valuation.DATE_OF_INSPECTION,
                    controller: controllers[Valuation.DATE_OF_INSPECTION]!,
                    icon: Icons.calendar_today_outlined,
                  ),
                  Divider(),
                  BasicField(
                    name: Valuation.BANK_BRANCH_VALUATION_TEAM_DETAILS,
                    controller: controllers[Valuation.BANK_BRANCH_VALUATION_TEAM_DETAILS]!,
                    icon: Icons.business_outlined,
                  ),
                  AreaField(
                    name: Valuation.NAME_OF_THE_OWNERS_AND_ADDRESSES_WITH_PHONE_NO,
                    controller: controllers[Valuation.NAME_OF_THE_OWNERS_AND_ADDRESSES_WITH_PHONE_NO]!,
                    icon: Icons.group_outlined,
                  ),
                  AreaField(
                    name: Valuation.PROPERTY_POSSESSION_NAMEPOSTAL_ADDRESS,
                    controller: controllers[Valuation.PROPERTY_POSSESSION_NAMEPOSTAL_ADDRESS]!,
                    icon: Icons.work_outline_outlined,
                  ),
                  AreaField(
                    name: Valuation.POCCESSION_CERTIFICATE_DETAILS,
                    controller: controllers[Valuation.POCCESSION_CERTIFICATE_DETAILS]!,
                    icon: Icons.article_outlined,
                  ),
                  AreaField(
                    name: Valuation.DEED_REG_SRO_NO_DATE,
                    controller: controllers[Valuation.DEED_REG_SRO_NO_DATE]!,
                    icon: Icons.assignment_ind_outlined,
                  ),
                  AreaField(
                    name: Valuation.LEGAL_REPORT_REFERENCE,
                    controller: controllers[Valuation.LEGAL_REPORT_REFERENCE]!,
                    icon: Icons.policy_outlined,
                  ),
                  AreaField(
                    name: Valuation.BUILDING_APPROVAL_REFERENCE,
                    controller: controllers[Valuation.BUILDING_APPROVAL_REFERENCE]!,
                    icon: Icons.verified_user_outlined,
                  ),
                  AreaField(
                    name: Valuation.PROPERTY_TAX_CERTICATE_DETAILS,
                    controller: controllers[Valuation.PROPERTY_TAX_CERTICATE_DETAILS]!,
                    icon: Icons.approval_outlined,
                  ),
                  AreaField(
                    name: Valuation.BUILDING_TAX_CERTIFICATE_DETAILS,
                    controller: controllers[Valuation.BUILDING_TAX_CERTIFICATE_DETAILS]!,
                    icon: Icons.account_balance_outlined,
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              padding: formPadding,
              child: Column(
                spacing: 24,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TableField(
                    title: "Property Area",
                    icon: Icons.straighten_outlined,
                    keyboardType: TextInputType.numberWithOptions(),
                    controllers: [
                      [controllers[Valuation.SURVEY_NO_RE_SY_NO_1]!, controllers[Valuation.AREA_IN_ARE_1]!],
                      [controllers[Valuation.SURVEY_NO_RE_SY_NO_2]!, controllers[Valuation.AREA_IN_ARE_2]!],
                      [controllers[Valuation.SURVEY_NO_RE_SY_NO_3]!, controllers[Valuation.AREA_IN_ARE_3]!],
                      [controllers[Valuation.SURVEY_NO_RE_SY_NO_4]!, controllers[Valuation.AREA_IN_ARE_4]!],
                    ],
                    fieldNames: [
                      ["Survey No./ Re. Sy. No.", "Area (in Are)"],
                      ["Survey No./ Re. Sy. No.", "Area (in Are)"],
                      ["Survey No./ Re. Sy. No.", "Area (in Are)"],
                      ["Survey No./ Re. Sy. No.", "Area (in Are)"],
                    ],
                  ),
                  TableField(
                    title: "Property Boundaries",
                    icon: Icons.aspect_ratio_outlined,
                    minRows: 4,
                    controllers: [
                      [controllers[Valuation.EAST_ACTUALS]!, controllers[Valuation.EAST_AS_PER_DEED]!],
                      [controllers[Valuation.SOUTH_ACTUALS]!, controllers[Valuation.SOUTH_AS_PER_DEED]!],
                      [controllers[Valuation.WEST_ACTUALS]!, controllers[Valuation.WEST_AS_PER_DEED]!],
                      [controllers[Valuation.NORTH_ACTUALS]!, controllers[Valuation.NORTH_AS_PER_DEED]!],
                    ],
                    fieldNames: [
                      [Valuation.EAST_ACTUALS, Valuation.EAST_AS_PER_DEED],
                      [Valuation.SOUTH_ACTUALS, Valuation.SOUTH_AS_PER_DEED],
                      [Valuation.WEST_ACTUALS, Valuation.WEST_AS_PER_DEED],
                      [Valuation.NORTH_ACTUALS, Valuation.NORTH_AS_PER_DEED],
                    ],
                  ),
                ],
              ),
            ),
            Text("Boo"),
            Text("Baa"),
            Text("Biii"),
          ],
        ),
      ),
    );
  }
}
