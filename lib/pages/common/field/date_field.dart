import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final IconData? icon;
  final String name;
  final bool required;
  final bool enabled;
  final bool isChild;
  final String focusField;

  const DatePickerField({
    super.key,
    required this.name,
    required this.controller,
    this.icon,
    this.required = false,
    this.isChild = false,
    this.enabled = true,
    this.focusField = "",
  });

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    DateTime initialDate = now;

    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateFormat('dd/MM/yyyy').parseStrict(controller.text);
      } catch (_) {
        initialDate = now;
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 24,
      children: [
        if (isChild) const SizedBox(width: 24),
        if (icon != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Icon(icon, size: 24),
          ),
        Expanded(
          child: GestureDetector(
            onTap: enabled ? () => _selectDate(context) : null,
            child: AbsorbPointer(
              child: TextFormField(
                controller: controller,
                enabled: enabled,
                autofocus: name == focusField,
                decoration: InputDecoration(
                  labelText: name,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.date_range),
                ),
                validator: (value) =>
                    required && (value == null || value.isEmpty) ? 'Required' : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
