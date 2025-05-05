import 'package:flutter/material.dart';

class AreaField extends StatelessWidget {
  final TextEditingController controller;
  final IconData? icon;
  final String name;
  final bool required;
  final bool enabled;
  const AreaField({
    super.key,
    required this.name,
    required this.controller,
    this.icon,
    this.required = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 24,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Icon(icon, size: 24)),
        Expanded(
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            maxLines: 3,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(labelText: name, alignLabelWithHint: true, border: const OutlineInputBorder()),
            validator: (value) => required && (value == null || value.isEmpty) ? 'Required' : null,
          ),
        ),
      ],
    );
  }
}
