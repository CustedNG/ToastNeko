import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

bool isDarkMode(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

void launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
