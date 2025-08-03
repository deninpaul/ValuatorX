// ignore_for_file: strict_top_level_inference, deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

String? getAuthCodeFromUrl() => Uri.parse(html.window.location.href).queryParameters['code'];

String goToUrl(Uri url) => html.window.location.href = url.toString();

String getUrl() => html.window.location.href;

html.WindowBase openWindow(url, name, options) => html.window.open(url, name, options);

StreamSubscription<html.MessageEvent> listenWindowMessage(void Function(html.MessageEvent)? onMessageRecieved) => html.window.onMessage.listen(onMessageRecieved);

void initWeb() => setUrlStrategy(PathUrlStrategy());