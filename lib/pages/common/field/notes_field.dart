import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';

class NotesField extends StatefulWidget {
  final TextEditingController controller;
  final String? placeholder;

  const NotesField({super.key, required this.controller, this.placeholder = "Write your notes..."});

  @override
  State<NotesField> createState() => _NotesFieldState();
}

class _NotesFieldState extends State<NotesField> {
  late QuillController _quillController;
  late FocusNode _focusNode;
  bool _isFocused = false;

  void _onTextChanged() {
    final jsonString = jsonEncode(_quillController.document.toDelta().toJson());
    widget.controller.text = jsonString;
  }

  void _onFocusChanged() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    Document doc;
    if (widget.controller.text.isNotEmpty) {
      try {
        final jsonData = jsonDecode(widget.controller.text);
        doc = Document.fromJson(jsonData);
      } catch (e) {
        doc = Document()..insert(0, widget.controller.text);
      }
    } else {
      doc = Document();
    }
    _quillController = QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0));
    _quillController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _quillController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: _isFocused ? colorScheme.primary : colorScheme.outline, width: _isFocused ? 2 : 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: QuillEditor.basic(
            controller: _quillController,
            focusNode: _focusNode,
            config: QuillEditorConfig(
              placeholder: widget.placeholder,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              autoFocus: false,
              expands: true,
              scrollable: true,
              customStyles: DefaultStyles(
                paragraph: DefaultTextBlockStyle(
                  textTheme.bodyLarge!,
                  const HorizontalSpacing(0, 0),
                  const VerticalSpacing(8, 8), // More space between paragraphs
                  const VerticalSpacing(0, 0),
                  null,
                ),
                placeHolder: DefaultTextBlockStyle(
                  textTheme.bodyLarge!.copyWith(color: colorScheme.outline),
                  HorizontalSpacing.zero,
                  VerticalSpacing.zero,
                  VerticalSpacing.zero,
                  null,
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.only(bottom: 24),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(color: colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(100)),
            child: QuillSimpleToolbar(
              controller: _quillController,
              config: QuillSimpleToolbarConfig(
                showBoldButton: true,
                showItalicButton: true,
                showUnderLineButton: true,
                showStrikeThrough: false,
                showInlineCode: false,
                showColorButton: false,
                showBackgroundColorButton: false,
                showClearFormat: false,
                showAlignmentButtons: false,
                showDirection: false,
                showHeaderStyle: false,
                showListNumbers: true,
                showListBullets: true,
                showListCheck: false,
                showCodeBlock: false,
                showQuote: true,
                showIndent: false,
                showLink: false,
                showUndo: true,
                showRedo: true,
                showFontFamily: false,
                showFontSize: false,
                showSubscript: false,
                showSuperscript: false,
                showSearchButton: false,
                toolbarSize: 40,
                toolbarSectionSpacing: 4,
                toolbarIconAlignment: WrapAlignment.start,
                showClipboardCopy: false,
                showClipboardCut: false,
                showClipboardPaste: false,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
