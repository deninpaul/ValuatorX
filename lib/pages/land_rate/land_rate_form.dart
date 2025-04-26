import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/modals/land_rate.dart';
import 'package:valuatorx/pages/common/texfields/basic_field.dart';
import 'package:valuatorx/pages/common/texfields/dropdown_field.dart';
import 'package:valuatorx/pages/common/texfields/location_field.dart';
import 'package:valuatorx/pages/land_rate/components/save_button.dart';
import 'package:valuatorx/providers/land_rate_provider.dart';

class LandRateForm extends StatefulWidget {
  const LandRateForm({super.key});

  @override
  State<LandRateForm> createState() => _LandRateFormState();
}

class _LandRateFormState extends State<LandRateForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {};
  final List<String> fieldKeys = LandRate.editableFields;

  @override
  void initState() {
    super.initState();
    for (final key in fieldKeys) {
      controllers[key] = TextEditingController();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setValues();
    });
  }

  setValues() async {
    final provider = Provider.of<LandRateProvider>(context, listen: false);
    if (provider.landRates.isEmpty) {
      controllers[LandRate.SL_NO]!.text = "Loading...";
      await provider.getLandRates(context, refresh: false);
    }
    controllers[LandRate.SL_NO]!.text = (provider.generateIndex() + 1).toString();
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  submitForm() async {
    final provider = Provider.of<LandRateProvider>(context, listen: false);
    final values = {for (final key in fieldKeys) key: controllers[key]!.text.trim(), "id": provider.generateIndex()};

    final LandRate newLandRate = LandRate.fromJson(values);
    await provider.addLandRate(context, newLandRate);
    await provider.getLandRates(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text("New Land Rate", style: textTheme.titleLarge),
        leading: IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        actions: [
          SaveButton(formKey: _formKey, onSubmit: submitForm),
          PopupMenuButton(offset: const Offset(0, 48), itemBuilder: (ctx) => [PopupMenuItem(child: Text("Clear form"))]),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 48, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 24,
            children: [
              BasicField(
                name: LandRate.SL_NO,
                controller: controllers[LandRate.SL_NO]!,
                icon: Icons.person_outline,
                enabled: false,
              ),
              LocationField(
                latitudeController: controllers["Lattitude"]!,
                longitudeController: controllers["Longitude"]!,
              ),
              BasicField(
                name: LandRate.LAND_RATE_PER_CENT,
                controller: controllers[LandRate.LAND_RATE_PER_CENT]!,
                icon: Icons.paid_outlined,
                required: true,
              ),
              BasicField(
                name: LandRate.LAND_SIZE_REMARKS,
                controller: controllers[LandRate.LAND_SIZE_REMARKS]!,
                icon: Icons.straighten_outlined,
              ),
              DropdownField(
                name: LandRate.LAND_TYPE,
                controller: controllers[LandRate.LAND_TYPE]!,
                options: LandRate.landTypeOptions,
                icon: Icons.landscape_outlined,
              ),
              DropdownField(
                name: LandRate.ROAD,
                controller: controllers[LandRate.ROAD]!,
                options: LandRate.roadOptions,
                icon: Icons.traffic_outlined,
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
    );
  }
}
