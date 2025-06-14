import 'dart:html' as html;

String? getAuthCodeFromUrl() => Uri.parse(html.window.location.href).queryParameters['code'];
void goToUrl(Uri url) => html.window.location.href = url.toString();