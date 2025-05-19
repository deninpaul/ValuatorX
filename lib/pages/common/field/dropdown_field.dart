import 'package:flutter/material.dart';

class DropdownField extends StatelessWidget {
  final TextEditingController controller;
  final List<String> options;
  final IconData? icon;
  final String name;
  final bool required;

  const DropdownField({super.key, required this.name, required this.controller, required this.options, this.icon, this.required = false});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      spacing: 24,
      children: [
        if (icon != null) Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Icon(icon, size: 24)),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: controller.text.isEmpty ? null : controller.text,
            items:
                options.map((option) {
                  return DropdownMenuItem<String>(value: option, child: Text(option, style: textTheme.bodyLarge));
                }).toList(),
            onChanged: (newValue) {
              if (newValue != null) controller.text = newValue;
            },
            decoration: InputDecoration(labelText: name, border: const OutlineInputBorder()),
            validator: (v) => required && (v == null || v.isEmpty) ? 'Required' : null,
          ),
        ),
      ],
    );
  }
}
