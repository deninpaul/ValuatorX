import 'package:flutter/material.dart';

class DropdownField extends StatefulWidget {
  final TextEditingController controller;
  final List<String> options;
  final IconData? icon;
  final String name;
  final bool required;
  final bool isChild;
  final String focusField;

  const DropdownField({
    super.key,
    required this.name,
    required this.controller,
    required this.options,
    this.icon,
    this.required = false,
    this.isChild = false,
    this.focusField = "",
  });

  @override
  State<DropdownField> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<DropdownField> {
  late List<String> _allOptions;

  @override
  void initState() {
    super.initState();
    _allOptions = [...widget.options, "Other (Custom)"];
  }

  void showCustomInputDialog() {
  showDialog(
    context: context,
    builder: (context) => CustomOptionDialog(
      label: widget.name,
      onSubmit: (value) {
        widget.controller.text = value;
        setState(() {});
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    bool isCustomValue = widget.controller.text.isNotEmpty && !widget.options.contains(widget.controller.text);

    return Row(
      spacing: 24,
      children: [
        if (widget.isChild) const SizedBox(width: 24),
        if (widget.icon != null) Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Icon(widget.icon, size: 24)),
        Expanded(
          child: DropdownButtonFormField<String>(
            autofocus: widget.name == widget.focusField,
            value: isCustomValue ? "Other (Custom)" : (widget.controller.text.isEmpty ? null : widget.controller.text),
            items:
                _allOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(
                      option == "Other (Custom)" && isCustomValue ? "Other: ${widget.controller.text}" : option,
                      style: textTheme.bodyLarge,
                    ),
                  );
                }).toList(),
            onChanged: (newValue) {
              if (newValue == "Other (Custom)") {
                showCustomInputDialog();
              } else if (newValue != null) {
                widget.controller.text = newValue;
                setState(() {});
              }
            },
            decoration: InputDecoration(labelText: widget.name, border: const OutlineInputBorder()),
            validator: (v) => widget.required && (widget.controller.text.isEmpty) ? 'Required' : null,
          ),
        ),
      ],
    );
  }
}

class CustomOptionDialog extends StatefulWidget {
  final String label;
  final void Function(String) onSubmit;
  const CustomOptionDialog({super.key, required this.label, required this.onSubmit});

  @override
  State<CustomOptionDialog> createState() => _CustomOptionDialogState();
}

class _CustomOptionDialogState extends State<CustomOptionDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter custom option'),
      content: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: SizedBox(
          width: 320,
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: widget.label, border: const OutlineInputBorder()),
            autofocus: true,
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onSubmit(_controller.text);
            }
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
