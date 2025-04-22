import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/modals/land_rate.dart';
import 'package:valuatorx/pages/common/location_field.dart';
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
    final values = {
      for (final key in fieldKeys) key: controllers[key]!.text.trim(),
      "id": provider.generateIndex(),
      "SL No": provider.generateIndex() + 1,
    };

    final LandRate newLandRate = LandRate.fromJson(values);
    await provider.addLandRate(context, newLandRate);
    await provider.getLandRates(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text("New Land Rate", style: textTheme.titleLarge),
        leading: IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        actions: [SaveButton(formKey: _formKey, onSubmit: submitForm)],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 48, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              LocationField(
                latitudeController: controllers["Lattitude"]!,
                longitudeController: controllers["Longitude"]!,
              ),

              ...fieldKeys.map((key) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: TextFormField(
                    controller: controllers[key],
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: key, // You can prettify this if needed
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
