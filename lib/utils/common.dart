import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:markdown_quill/markdown_quill.dart';
import 'package:markdown/markdown.dart' as markdown;

final headerTheme = TextStyle(fontSize: 16);

final mdDocument = markdown.Document(encodeHtml: false);
final mdToDelta = MarkdownToDelta(markdownDocument: mdDocument);
final deltaToMd = DeltaToMarkdown();

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
void showSnackbar(String message) {
  scaffoldMessengerKey.currentState?.clearSnackBars();
  scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
}

defaultTransition(Color color, {SharedAxisTransitionType orientation = SharedAxisTransitionType.horizontal}) {
  return (child, animation, secondaryAnimation) => SharedAxisTransition(
    animation: animation,
    secondaryAnimation: secondaryAnimation,
    transitionType: orientation,
    fillColor: color,
    child: child,
  );
}

String getExcelColumn(int num) {
  String column = '';
  while (num > 0) {
    int remainder = (num - 1) % 26;
    column = String.fromCharCode(65 + remainder) + column;
    num = (num - 1) ~/ 26;
  }
  return column;
}

bool isMobile(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return width < 600;
}

bool isDesktop(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return width > 1280;
}

EdgeInsets formPadding(context) => EdgeInsets.symmetric(horizontal: isMobile(context) ? 24 : (isDesktop(context) ? 240 : 48), vertical: 32);

String normalizeString(String input) {
  return input.toLowerCase().replaceAll(RegExp(r'[^\w]+'), ' ').trim();
}

String extractPersons(String input) {
  final results = <String>[];
  input = input.replaceAll("\n", ", ");
  input = input.replaceAll("&", ", ");
  input = input.replaceAllMapped(
    RegExp(r'\b(S/o|D/o|W/o|F/o)\s*,\s*(Mr\.|Mrs\.|Ms\.|Dr\.|M/s\.)?\s*([A-Za-z@.\s]+)', caseSensitive: false),
    (m) => '${m.group(1)} ${m.group(2)?.trim() ?? ''}${m.group(3)?.trim() ?? ''}',
  );
  final relationRegex = RegExp(
    r'(?:\b(Mr\.|Mrs\.|Ms\.|M/s\.|Miss|Dr\.)\s*)?([A-Za-z.\s]+?)\s*,?\s*(S/o|D/o|W/o|F/o)\s*([A-Za-z.\s@&]*)',
    caseSensitive: false,
  );
  for (final match in relationRegex.allMatches(input)) {
    final title = match.group(1)?.trim() ?? '';
    final name = match.group(2)?.trim().replaceAll(RegExp(r'^[.\s]+|[.\s]+$'), '') ?? '';
    final relation = match.group(3);
    final relatedTo = (match.group(4) ?? '').split('&').first.split(',').first.replaceAll('@', '').trim();
    final fullName = '$title$name';
    results.add(relatedTo.isNotEmpty ? '$fullName ($relation $relatedTo)' : '$fullName ($relation)');
  }
  if (results.isEmpty) {
    final justNameRegex = RegExp(r'\b(Mr\.|Mrs\.|Ms\.|M/s\.|Miss|Dr\.)\s*([A-Za-z]+(?:\s+[A-Za-z.]+)?)', caseSensitive: false);
    for (final match in justNameRegex.allMatches(input)) {
      final title = match.group(1)?.trim() ?? '';
      final name = match.group(2)?.trim() ?? '';
      results.add('$title$name');
    }
  }
  if (results.isEmpty) {
    final rawName = input.trim().split(RegExp(r'[,.\n]')).firstWhere((part) => part.trim().isNotEmpty, orElse: () => '');
    if (rawName.isNotEmpty) results.add(rawName.trim());
  }
  return results.take(2).join(', ');
}

String formatCamelCase (String input) {
  return input.replaceAllMapped(
    RegExp(r'([a-z])([A-Z])'),
    (match) => '${match.group(1)} ${match.group(2)}',
  );
}

Color darkenColor(Color color, [double amount = .05]) {
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return hslDark.toColor();
}