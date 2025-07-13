import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/models/valuation.dart';
import 'package:valuatorx/pages/common/modal/discard_dialog.dart';
import 'package:valuatorx/pages/common/modal/draft_dialog.dart';
import 'package:valuatorx/pages/common/field/area_field.dart';
import 'package:valuatorx/pages/common/field/basic_field.dart';
import 'package:valuatorx/pages/common/field/date_field.dart';
import 'package:valuatorx/pages/common/field/dropdown_field.dart';
import 'package:valuatorx/pages/common/field/location_field.dart';
import 'package:valuatorx/pages/common/field/notes_field.dart';
import 'package:valuatorx/pages/common/field/table_field.dart';
import 'package:valuatorx/pages/common/button/save_button.dart';
import 'package:valuatorx/pages/common/image/image_picker.dart';
import 'package:valuatorx/providers/valuation_provider.dart';
import 'package:valuatorx/utils/common.dart';

class ValuationForm extends StatefulWidget {
  final bool editMode;
  final bool isDraft;
  final String focusField;
  final int focusTabIndex;
  const ValuationForm({super.key, this.editMode = false, this.isDraft = false, this.focusField = "", this.focusTabIndex = 0});

  @override
  State<ValuationForm> createState() => _ValuationFormState();
}

class _ValuationFormState extends State<ValuationForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {};
  final List<String> fieldKeys = Valuation.editableFields;
  final List<String> tabs = ["General Details", "Land Details", "Building Details", "Notes", "Photo"];

  late TabController _tabController;
  late String draftId;
  late Valuation baseValue;

  bool showDraftDialog = false;
  bool ready = false;
  Timer? timer;

  Valuation generateValuation(String? id, {String? status}) {
    final values = {
      for (final key in fieldKeys) key: controllers[key]!.text.trim(),
      if (status != null) Valuation.STATUS: status,
      Valuation.ID: id ?? "",
    };
    return Valuation.fromJson(values);
  }

  populateForm() async {
    final provider = Provider.of<ValuationProvider>(context, listen: false);
    baseValue =
        widget.editMode
            ? provider.getSelectedValuation()
            : Valuation.fromJson({Valuation.DATE_OF_INSPECTION: DateFormat('dd/MM/yyyy').format(DateTime.now())});
    final values = baseValue.toJson();
    for (final key in fieldKeys) {
      controllers[key]!.text = values[key];
    }
    final draftExist = await provider.draftExists(baseValue);
    setState(() {
      showDraftDialog = draftExist;
      ready = true;
    });
  }

  syncToDraft() async {
    final provider = Provider.of<ValuationProvider>(context, listen: false);
    draftId = widget.editMode ? provider.getSelectedValuation().id : await provider.generateDraftIndex();
    timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;
      final valuation = generateValuation(draftId, status: "Draft");
      if (!valuation.equal(baseValue)) {
        await provider.createOrUpdateDraft(valuation);
      }
    });
  }

  saveDraft() async {
    final provider = Provider.of<ValuationProvider>(context, listen: false);
    final valuation = generateValuation(draftId, status: "Draft");
    await provider.createOrUpdateDraft(valuation);
  }

  loadDraft() async {
    final provider = Provider.of<ValuationProvider>(context, listen: false);
    final values = await provider.getDraft(draftId);
    for (final key in fieldKeys) {
      controllers[key]!.text = values[key];
    }
    setState(() => showDraftDialog = false);
  }

  cancelDraft() async {
    final provider = Provider.of<ValuationProvider>(context, listen: false);
    await provider.deleteDraft(draftId);
    setState(() => showDraftDialog = false);
  }

  submitForm() async {
    final provider = Provider.of<ValuationProvider>(context, listen: false);
    final id = widget.editMode && !widget.isDraft ? provider.getSelectedValuation().id : provider.generateIndex();
    final valuation = generateValuation(id);
    valuation.status = Valuation.statusOptions[0];
    final done =
        widget.editMode && !widget.isDraft
            ? await provider.updateValuation(context, valuation)
            : await provider.addValuations(context, valuation);
    if (done) {
      await provider.deleteDraft(draftId);
      if (widget.isDraft) {
        provider.setSelectedItem(id);
      }
    }
  }

  cancelForm() async {
    final provider = Provider.of<ValuationProvider>(context, listen: false);
    final id = widget.editMode && !widget.isDraft ? provider.getSelectedValuation().id : provider.generateIndex();
    final valuation = generateValuation(id);
    if (!valuation.equal(baseValue)) {
      await showDialog<bool>(
        context: context,
        builder:
            (ctx) => DiscardDialog(
              actions: {"Discard": cancelDraft, if (widget.editMode) "Save changes": submitForm else "Save as draft": saveDraft},
            ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    for (final key in fieldKeys) {
      controllers[key] = TextEditingController();
    }
    _tabController = TabController(length: tabs.length, vsync: this, initialIndex: widget.focusTabIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      populateForm();
      syncToDraft();
    });
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    _tabController.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modeName = widget.editMode ? "Edit" : "New";
    final provider = Provider.of<ValuationProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 72,
        title: Text("$modeName Valuation Report", style: headerTheme),
        leading: IconButton(icon: Icon(Icons.close), onPressed: cancelForm),
        actions: [
          SaveButton(formKey: _formKey, onSubmit: submitForm, enabled: ready, creating: provider.isCreating),
          if (kIsWeb) SizedBox(width: 8),
          PopupMenuButton(offset: const Offset(0, 48), itemBuilder: (ctx) => [PopupMenuItem(child: Text("Clear form"))]),
          if (kIsWeb) SizedBox(width: 8),
        ],
        bottom: TabBar(controller: _tabController, isScrollable: true, tabs: tabs.map((tab) => Tab(text: tab)).toList()),
      ),
      body: Form(
        key: _formKey,
        canPop: false,
        onPopInvokedWithResult: (bool didPop, _) {
          if (didPop) return;
          cancelForm();
        },
        child: Column(
          children: [
            if (showDraftDialog) DraftDialog(onLoad: loadDraft, onCancel: cancelDraft),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SingleChildScrollView(
                    padding: formPadding(context),
                    child: Column(
                      spacing: 24,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BasicField(
                          name: Valuation.REPORT_REFERENCE,
                          controller: controllers[Valuation.REPORT_REFERENCE]!,
                          icon: Icons.person_outline,
                          focusField: widget.focusField,
                          type: TextInputType.numberWithOptions(),
                          required: true,
                        ),
                        DatePickerField(
                          name: Valuation.DATE_OF_INSPECTION,
                          controller: controllers[Valuation.DATE_OF_INSPECTION]!,
                          icon: Icons.calendar_today_outlined,
                          focusField: widget.focusField,
                          required: true,
                        ),
                        BasicField(
                          name: Valuation.FILE_ALLOCATION_DETAIL,
                          controller: controllers[Valuation.FILE_ALLOCATION_DETAIL]!,
                          icon: Icons.business_outlined,
                          focusField: widget.focusField,
                        ),
                        Divider(),
                        AreaField(
                          name: Valuation.MORTGAGOR_DETAIL,
                          controller: controllers[Valuation.MORTGAGOR_DETAIL]!,
                          icon: Icons.group_outlined,
                          focusField: widget.focusField,
                        ),
                        BasicField(
                          name: Valuation.MORTGAGOR_MOBILE,
                          controller: controllers[Valuation.MORTGAGOR_MOBILE]!,
                          icon: Icons.dialpad,
                          focusField: widget.focusField,
                          type: TextInputType.numberWithOptions(),
                        ),
                        AreaField(
                          name: Valuation.DEED_OWNER_DETAIL,
                          controller: controllers[Valuation.DEED_OWNER_DETAIL]!,
                          icon: Icons.work_outline_outlined,
                          focusField: widget.focusField,
                        ),
                        AreaField(
                          name: Valuation.LEGAL_REPORT_REFERENCE,
                          controller: controllers[Valuation.LEGAL_REPORT_REFERENCE]!,
                          icon: Icons.policy_outlined,
                          focusField: widget.focusField,
                        ),
                        AreaField(
                          name: Valuation.DEED_DOCUMENT_DETAILS,
                          controller: controllers[Valuation.DEED_DOCUMENT_DETAILS]!,
                          icon: Icons.assignment_ind_outlined,
                          focusField: widget.focusField,
                        ),
                        AreaField(
                          name: Valuation.POCCESSION_CERTIFICATE_DETAILS,
                          controller: controllers[Valuation.POCCESSION_CERTIFICATE_DETAILS]!,
                          icon: Icons.article_outlined,
                          focusField: widget.focusField,
                        ),
                        AreaField(
                          name: Valuation.LOCATION_SKETCH_DETAILS,
                          controller: controllers[Valuation.LOCATION_SKETCH_DETAILS]!,
                          icon: Icons.edit_location_alt_outlined,
                          focusField: widget.focusField,
                        ),
                        AreaField(
                          name: Valuation.PROPERTY_TAX_CERTICATE_DETAILS,
                          controller: controllers[Valuation.PROPERTY_TAX_CERTICATE_DETAILS]!,
                          icon: Icons.approval_outlined,
                          focusField: widget.focusField,
                        ),
                        AreaField(
                          name: Valuation.BUILDING_TAX_CERTIFICATE_DETAILS,
                          controller: controllers[Valuation.BUILDING_TAX_CERTIFICATE_DETAILS]!,
                          icon: Icons.account_balance_outlined,
                          focusField: widget.focusField,
                        ),
                        AreaField(
                          name: Valuation.BUILDING_APPROVAL_REFERENCE,
                          controller: controllers[Valuation.BUILDING_APPROVAL_REFERENCE]!,
                          icon: Icons.verified_user_outlined,
                          focusField: widget.focusField,
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    padding: formPadding(context),
                    child: Column(
                      spacing: 24,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TableField(
                          title: "Property Area",
                          icon: Icons.straighten_outlined,
                          focusField: widget.focusField,
                          minRows: 2,
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
                        Divider(),
                        BasicField(
                          name: Valuation.VILLAGE,
                          controller: controllers[Valuation.VILLAGE]!,
                          focusField: widget.focusField,
                          icon: Icons.cottage_outlined,
                        ),
                        BasicField(
                          name: Valuation.TALUK,
                          controller: controllers[Valuation.TALUK]!,
                          focusField: widget.focusField,
                          isChild: true,
                        ),
                        BasicField(
                          name: Valuation.PANCHAYATH,
                          controller: controllers[Valuation.PANCHAYATH]!,
                          icon: Icons.account_balance_outlined,
                          focusField: widget.focusField,
                        ),
                        BasicField(
                          name: Valuation.MAIN_CENTER,
                          controller: controllers[Valuation.MAIN_CENTER]!,
                          focusField: widget.focusField,
                          isChild: true,
                        ),
                        BasicField(
                          name: Valuation.NEARBY_TOWN,
                          controller: controllers[Valuation.NEARBY_TOWN]!,
                          focusField: widget.focusField,
                          icon: Icons.flag_outlined,
                        ),
                        AreaField(
                          name: Valuation.LANDMARK_OF_THE_PROPERTY,
                          controller: controllers[Valuation.LANDMARK_OF_THE_PROPERTY]!,
                          focusField: widget.focusField,
                          isChild: true,
                        ),
                        Divider(),
                        LocationField(
                          latitudeController: controllers[Valuation.LATTITUDE]!,
                          longitudeController: controllers[Valuation.LONGITUDE]!,
                          focusField: widget.focusField,
                          icon: Icons.gps_fixed_outlined,
                        ),
                        TableField(
                          title: "Property Boundaries",
                          icon: Icons.aspect_ratio_outlined,
                          focusField: widget.focusField,
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
                        BasicField(
                          name: Valuation.ROAD_DETAILS,
                          controller: controllers[Valuation.ROAD_DETAILS]!,
                          focusField: widget.focusField,
                          icon: Icons.route_outlined,
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    padding: formPadding(context),
                    child: Column(
                      spacing: 24,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BasicField(
                          name: Valuation.HOUSE_NO_DOOR_NO,
                          controller: controllers[Valuation.HOUSE_NO_DOOR_NO]!,
                          icon: Icons.sensor_door_outlined,
                          focusField: widget.focusField,
                        ),
                        BasicField(
                          name: Valuation.ELECTRICITY_CONSUMER_NO,
                          controller: controllers[Valuation.ELECTRICITY_CONSUMER_NO]!,
                          icon: Icons.lightbulb_outline,
                          focusField: widget.focusField,
                        ),
                        AreaField(
                          name: Valuation.BUILDING_DESCRIPTION,
                          controller: controllers[Valuation.BUILDING_DESCRIPTION]!,
                          icon: Icons.description_outlined,
                          focusField: widget.focusField,
                        ),
                        BasicField(
                          name: Valuation.YEAR_OF_CONSTRUCTION,
                          controller: controllers[Valuation.YEAR_OF_CONSTRUCTION]!,
                          focusField: widget.focusField,
                          icon: Icons.event_outlined,
                        ),
                        DropdownField(
                          name: Valuation.TYPE_OF_CONSTRUCTION,
                          controller: controllers[Valuation.TYPE_OF_CONSTRUCTION]!,
                          options: Valuation.constructionTypeOptions,
                          icon: Icons.factory_outlined,
                          focusField: widget.focusField,
                        ),
                        DropdownField(
                          name: Valuation.TYPE_OF_BUILDING,
                          controller: controllers[Valuation.TYPE_OF_BUILDING]!,
                          options: Valuation.buildingTypeOptions,
                          icon: Icons.category_outlined,
                          focusField: widget.focusField,
                        ),
                        DropdownField(
                          name: Valuation.CONDITION_OF_BUILDING_EXTERIOR,
                          controller: controllers[Valuation.CONDITION_OF_BUILDING_EXTERIOR]!,
                          options: Valuation.exteriorConditionOptions,
                          icon: Icons.verified_outlined,
                          focusField: widget.focusField,
                        ),
                        DropdownField(
                          name: Valuation.CONDITION_OF_BUILDING_INTERIOR,
                          controller: controllers[Valuation.CONDITION_OF_BUILDING_INTERIOR]!,
                          options: Valuation.interiorConditionOptions,
                          focusField: widget.focusField,
                          isChild: true,
                        ),
                        Divider(),
                        DropdownField(
                          name: Valuation.FOUNDATION_BASEMENT,
                          controller: controllers[Valuation.FOUNDATION_BASEMENT]!,
                          options: Valuation.foundationOptions,
                          icon: Icons.foundation_outlined,
                          focusField: widget.focusField,
                        ),
                        DropdownField(
                          name: Valuation.WALL_DETAILS,
                          controller: controllers[Valuation.WALL_DETAILS]!,
                          options: Valuation.wallOptions,
                          icon: Icons.width_full_outlined,
                          focusField: widget.focusField,
                        ),
                        DropdownField(
                          name: Valuation.ROOFING,
                          controller: controllers[Valuation.ROOFING]!,
                          options: Valuation.roofOptions,
                          icon: Icons.gite_outlined,
                          focusField: widget.focusField,
                        ),
                        BasicField(
                          name: Valuation.FLOORING,
                          controller: controllers[Valuation.FLOORING]!,
                          icon: Icons.dashboard_outlined,
                          focusField: widget.focusField,
                        ),
                        DropdownField(
                          name: Valuation.CEILING_FINISH,
                          controller: controllers[Valuation.CEILING_FINISH]!,
                          options: Valuation.ceilingOptions,
                          icon: Icons.ac_unit_outlined,
                          focusField: widget.focusField,
                        ),
                        DropdownField(
                          name: Valuation.WINDOWS,
                          controller: controllers[Valuation.WINDOWS]!,
                          options: Valuation.windowOptions,
                          icon: Icons.window_outlined,
                          focusField: widget.focusField,
                        ),
                        DropdownField(
                          name: Valuation.DOORS,
                          controller: controllers[Valuation.DOORS]!,
                          options: Valuation.doorOptions,
                          icon: Icons.sensor_door_outlined,
                          focusField: widget.focusField,
                        ),
                        DropdownField(
                          name: Valuation.RCC_WORKS,
                          controller: controllers[Valuation.RCC_WORKS]!,
                          options: Valuation.rccProtectionOptions,
                          icon: Icons.grid_3x3_outlined,
                          focusField: widget.focusField,
                        ),
                        Divider(),
                        TableField(
                          title: "Floor measurements",
                          icon: Icons.straighten_outlined,
                          focusField: widget.focusField,
                          minRows: 2,
                          controllers: [
                            [controllers[Valuation.PLINT_AREA_GF]!, controllers[Valuation.REPLACEMENT_RATE_GF]!],
                            [controllers[Valuation.PLINTH_AREA_FF]!, controllers[Valuation.REPLACEMENT_RATE_FF]!],
                            [controllers[Valuation.PLINTH_AREA_SF]!, controllers[Valuation.REPLACEMENT_RATE_SF]!],
                            [controllers[Valuation.PLINTH_AREA_TF]!, controllers[Valuation.REPLACEMENT_RATE_TF]!],
                          ],
                          fieldNames: [
                            [Valuation.PLINT_AREA_GF, Valuation.REPLACEMENT_RATE_GF],
                            [Valuation.PLINTH_AREA_FF, Valuation.REPLACEMENT_RATE_FF],
                            [Valuation.PLINTH_AREA_SF, Valuation.REPLACEMENT_RATE_SF],
                            [Valuation.PLINTH_AREA_TF, Valuation.REPLACEMENT_RATE_TF],
                          ],
                        ),
                        BasicField(
                          name: Valuation.PREVAILING_AREA_RATE_AT_CENTER,
                          controller: controllers[Valuation.PREVAILING_AREA_RATE_AT_CENTER]!,
                          icon: Icons.paid_outlined,
                          focusField: widget.focusField,
                        ),
                        BasicField(
                          name: Valuation.PROPERTY_AREA_RATE,
                          controller: controllers[Valuation.PROPERTY_AREA_RATE]!,
                          focusField: widget.focusField,
                          icon: Icons.sell_outlined,
                        ),
                        BasicField(
                          name: Valuation.BUILDING_REPLACEMENT_RATE,
                          controller: controllers[Valuation.BUILDING_REPLACEMENT_RATE]!,
                          focusField: widget.focusField,
                          icon: Icons.toll_outlined,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: formPadding(context),
                    child: ready ? NotesField(controller: controllers[Valuation.REMARKS]!) : CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: formPadding(context),
                    child: ImagePickerField(controller: controllers[Valuation.PHOTOS]!, editMode: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
