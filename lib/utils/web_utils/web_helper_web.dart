import 'dart:html' as html;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

String? getAuthCodeFromUrl() => Uri.parse(html.window.location.href).queryParameters['code'];

goToUrl(Uri url) => html.window.location.href = url.toString();

String getUrl() => html.window.location.href;

openWindow(url, name, options) => html.window.open(url, name, options);

listenWindowMessage(void Function(html.MessageEvent)? onMessageRecieved) => html.window.onMessage.listen(onMessageRecieved);

initWeb() => setUrlStrategy(PathUrlStrategy());