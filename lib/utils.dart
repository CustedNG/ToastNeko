import 'dart:convert';

import 'package:cat_gallery/core/request.dart';
import 'package:cat_gallery/data/ge.dart';
import 'package:cat_gallery/route.dart';
import 'package:cat_gallery/store/cat_store.dart';
import 'package:cat_gallery/update.dart';
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

Future<void> initCatData([String nekoId]) async {
  Map<String, dynamic> jsonData;
  final catStore = CatStore();
  await catStore.init();
  
  if(nekoId != null){
    await Request().go(
        'get',
        Strs.publicGetCatDetail,
        data: {'neko_id': nekoId},
        success: (value) async {
          jsonData = json.decode(value);
          catStore.put(nekoId, json.encode(jsonData));
        },
        failed: (code) => print(code)
    );
    return;
  }
  List<String> catId = [];
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

void showSnackBar(BuildContext context, String content){
  Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
      )
  );
}

Future<void> checkVersion(BuildContext context) async {
  await Request().go(
      'get',
      Strs.publicGetVersion,
      success: (data){
        Map<String, dynamic> jsonData = json.decode(data);
        int version = int.parse(jsonData['version']);
        print(version > Strs.versionCode);
        if(version > Strs.versionCode)AppRoute(
            UpdatePage(
              version: version,
              android: jsonData['android'],
              ios: jsonData['ios'],
            )
        ).go(context);
      }
  );
}

void unawaited(Future<void> future) {}