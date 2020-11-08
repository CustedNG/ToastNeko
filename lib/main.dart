import 'dart:io';

import 'package:cat_gallery/app.dart';
import 'package:cat_gallery/data/cat_provider.dart';
import 'package:cat_gallery/data/user_provider.dart';
import 'package:cat_gallery/locator.dart';
import 'package:cat_gallery/utils.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

UserProvider userProvider = locator<UserProvider>();
CatProvider catProvider = locator<CatProvider>();

Future<void> init() async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);
  await setupLocator(appDocDir.path);
  await initCatData();
  userProvider.loadLocalData();
  catProvider.loadData();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => userProvider),
          ChangeNotifierProvider(create: (_) => catProvider),
        ],
        child: MyApp(),
      )
  );
}