import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/models/land_rate.dart';
import 'package:valuatorx/pages/common/field/basic_field.dart';
import 'package:valuatorx/pages/common/field/dropdown_field.dart';
import 'package:valuatorx/pages/common/field/location_field.dart';
import 'package:valuatorx/pages/common/button/save_button.dart';
import 'package:valuatorx/pages/common/modal/discard_dialog.dart';
import 'package:valuatorx/providers/land_rate_provider.dart';
import 'package:valuatorx/utils/common.dart';

class LandRateForm extends StatefulWidget {
  final bool editMode;
  final String focusField;
  const LandRateForm({super.key, this.editMode = false, this.focusField = ""});

  @override
  State<LandRateForm> createState() => _LandRateFormState();
}

class _LandRateFormState extends State<LandRateForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {};
  final List<String> fieldKeys = LandRate.editableFields;
  late final LandRate baseValue;
  bool ready = false;

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  LandRate generateLandRate(String id) {
    final values = {for (final key in fieldKeys) key: controllers[key]!.text.trim(), "id": id};
    values[LandRate.COORDINATES] = "${values[LandRate.LATITUDE]}, ${values[LandRate.LONGITUDE]}";
    return LandRate.fromJson(values);
  }

  Future<void> populateForm() async {
    final provider = Provider.of<LandRateProvider>(context, listen: false);
    if (!widget.editMode) {
      if (provider.landRates.isEmpty) {
        controllers[LandRate.SL_NO]!.text = "Loading...";
        await provider.getLandRates(context, refresh: false);
      }
    }
    baseValue =
        widget.editMode
            ? provider.getSelectedLandRate()
            : LandRate.fromJson({LandRate.AUTHOR: provider.selectedTable, LandRate.SL_NO: provider.generateIndex()});
    final values = baseValue.toJson();
    for (final key in fieldKeys) {
      controllers[key]!.text = values[key];
    }

    setState(() => ready = true);
  }

  Future<void> submitForm() async {
    final provider = Provider.of<LandRateProvider>(context, listen: false);
    final id = widget.editMode ? provider.getSelectedLandRate().id : provider.generateIndex();
    final newLandRate = generateLandRate(id);
    if (widget.editMode) {
      await provider.updateLandRate(context, newLandRate);
    } else {
      await provider.addLandRate(context, newLandRate);
    }
  }

  Future<void> cancelForm() async {
    final provider = Provider.of<LandRateProvider>(context, listen: false);
    final id = widget.editMode ? provider.getSelectedLandRate().id : provider.generateIndex();
    final newLandRate = generateLandRate(id);
    if (!newLandRate.equal(baseValue)) {
      await showDialog<bool>(context: context, builder: (ctx) => DiscardDialog(actions: {"Discard": () {}}));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final modeName = widget.editMode ? "Edit" : "New";
    final provider = Provider.of<LandRateProvider>(context);

    void updateSerialNumber(String newAuthor) {
      provider.setSelectedTable(newAuthor);
      controllers[LandRate.SL_NO]!.text = provider.generateIndex();
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          title: Text("$modeName Land Rate", style: headerTheme),
          leading: IconButton(icon: Icon(Icons.close), onPressed: cancelForm),
          actions: [
            SaveButton(formKey: _formKey, onSubmit: submitForm, enabled: ready, creating: provider.isCreating),
            PopupMenuButton(
              icon: Icon(Icons.more_vert),
              offset: const Offset(0, 48),
              itemBuilder: (ctx) => [PopupMenuItem(child: Text("Clear form"))],
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: formPadding(context),
          child: Form(
            key: _formKey,
            canPop: false,
            onPopInvokedWithResult: (bool didPop, _) {
              if (didPop) return;
              cancelForm();
            },
            child: Column(
              spacing: 24,
              children: [
                BasicField(
                  name: LandRate.SL_NO,
                  controller: controllers[LandRate.SL_NO]!,
                  icon: Icons.person_outline,
                  enabled: false,
                  focusField: widget.focusField,
                ),
                DropdownField(
                  name: LandRate.AUTHOR,
                  controller: controllers[LandRate.AUTHOR]!,
                  options: LandRate.tables,
                  focusField: widget.focusField,
                  allowCustomValues: false,
                  onComplete: updateSerialNumber,
                  enabled: !widget.editMode,
                  isChild: true,
                ),
                LocationField(
                  latitudeController: controllers[LandRate.LATITUDE]!,
                  longitudeController: controllers[LandRate.LONGITUDE]!,
                  focusField: widget.focusField,
                ),
                BasicField(
                  name: LandRate.LAND_RATE_PER_CENT,
                  controller: controllers[LandRate.LAND_RATE_PER_CENT]!,
                  icon: Icons.paid_outlined,
                  focusField: widget.focusField,
                  required: true,
                ),
                BasicField(
                  name: LandRate.LAND_SIZE_REMARKS,
                  controller: controllers[LandRate.LAND_SIZE_REMARKS]!,
                  focusField: widget.focusField,
                  icon: Icons.straighten_outlined,
                ),
                DropdownField(
                  name: LandRate.LAND_TYPE,
                  controller: controllers[LandRate.LAND_TYPE]!,
                  options: LandRate.landTypeOptions,
                  icon: Icons.landscape_outlined,
                  focusField: widget.focusField,
                ),
                DropdownField(
                  name: LandRate.ROAD,
                  controller: controllers[LandRate.ROAD]!,
                  options: LandRate.roadOptions,
                  icon: Icons.traffic_outlined,
                  focusField: widget.focusField,
                ),
                Row(
                  spacing: 24,
                  children: [
                    Flexible(
                      child: DropdownField(
                        name: LandRate.MONTH_OF_VISIT,
                        controller: controllers[LandRate.MONTH_OF_VISIT]!,
                        options: LandRate.monthOptions,
                        icon: Icons.calendar_today_outlined,
                      ),
                    ),
                    Flexible(
                      child: BasicField(
                        name: LandRate.YEAR_OF_VISIT,
                        controller: controllers[LandRate.YEAR_OF_VISIT]!,
                        type: TextInputType.numberWithOptions(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
