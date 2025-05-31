import 'package:flutter/material.dart';

class BasicField extends StatelessWidget {
  final TextEditingController controller;
  final IconData? icon;
  final String name;
  final bool required;
  final bool enabled;
  final bool isChild;
  final String focusField;
  final TextInputType type;
  const BasicField({
    super.key,
    required this.name,
    required this.controller,
    this.icon,
    this.type = TextInputType.text,
    this.required = false,
    this.isChild = false,
    this.enabled = true,
    this.focusField = "",
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 24,
      children: [
        if (isChild) SizedBox(width: 24),
        if (icon != null) Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Icon(icon, size: 24)),
        Expanded(
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            autofocus: name == focusField,
            textInputAction: TextInputAction.next,
            keyboardType: type,
            decoration: InputDecoration(labelText: name, border: const OutlineInputBorder()),
            validator: (value) => required && (value == null || value.isEmpty) ? 'Required' : null,
          ),
        ),
      ],
    );
  }
}
