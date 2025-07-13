import 'package:flutter/material.dart';

class AreaField extends StatelessWidget {
  final TextEditingController controller;
  final IconData? icon;
  final String name;
  final bool required;
  final bool enabled;
  final String focusField;
  final bool isChild;
  const AreaField({
    super.key,
    required this.name,
    required this.controller,
    this.icon,
    this.required = false,
    this.enabled = true,
    this.focusField = "",
    this.isChild = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 24,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isChild) SizedBox(width: 20),
        if (icon != null) Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Icon(icon)),
        Expanded(
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            minLines: 3,
            maxLines: null,
            autofocus: name == focusField,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(labelText: name, alignLabelWithHint: true, border: const OutlineInputBorder()),
            validator: (value) => required && (value == null || value.isEmpty) ? 'Required' : null,
          ),
        ),
      ],
    );
  }
}
