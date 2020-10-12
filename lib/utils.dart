import 'dart:convert';

import 'package:cat_gallery/core/request.dart';
import 'package:cat_gallery/data/ge.dart';
import 'package:cat_gallery/store/cat_store.dart';
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

Future<void> initCatData() async {
  List<String> catId = [];
  Map<String, dynamic> jsonData;
  final catStore = CatStore();
  await catStore.init();

  await Request().go(
      'get',
      Strs.publicGetAllCats,
      success: (value) async {
        jsonData = json.decode(value);
        jsonData['neko_list'].forEach((cat) => catId.add(cat['neko_id']));
        catStore.allCats.put(json.encode(jsonData));
      },
      failed: (code) => print(code)
  );
  for(String id in catId){
    await Request().go(
        'get',
        Strs.publicGetCatDetail,
        data: {'neko_id': id},
        success: (value) async {
          jsonData = json.decode(value);
          catStore.put(id, json.encode(jsonData));
        },
        failed: (code) => print(code)
    );
  }
}
