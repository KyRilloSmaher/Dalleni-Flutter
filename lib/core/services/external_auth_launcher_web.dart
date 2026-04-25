import 'dart:html' as html;

Future<bool> launchExternalAuthUrl(String url) async {
  html.window.location.assign(url);
  return true;
}
