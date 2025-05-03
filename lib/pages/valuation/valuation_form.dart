import 'package:flutter/material.dart';
import 'package:valuatorx/modals/valuation.dart';
import 'package:valuatorx/pages/common/fields/basic_field.dart';
import 'package:valuatorx/pages/land_rate/components/save_button.dart';

class ValuationForm extends StatefulWidget {
  final bool editMode;
  const ValuationForm({super.key, this.editMode = false});

  @override
  State<ValuationForm> createState() => _ValuationFormState();
}

class _ValuationFormState extends State<ValuationForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {};
  final List<String> fieldKeys = Valuation.editableFields;
  bool ready = true;

  @override
  void initState() {
    super.initState();
    for (final key in fieldKeys) {
      controllers[key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final modeName = widget.editMode ? "Edit" : "New";

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text("$modeName Land Rate", style: textTheme.titleLarge!.copyWith(fontSize: 19)),
        leading: IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        actions: [
          SaveButton(formKey: _formKey, onSubmit: () {}, enabled: ready),
          PopupMenuButton(
            offset: const Offset(0, 48),
            itemBuilder: (ctx) => [PopupMenuItem(child: Text("Clear form"))],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 48, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 24,
            children: [
              SizedBox(height: 8),
              BasicField(
                name: Valuation.REPORT_NAME,
                controller: controllers[Valuation.REPORT_NAME]!,
                icon: Icons.person_outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
