import 'dart:async';
import 'dart:convert';

import 'package:cat_gallery/core/provider.dart';
import 'package:cat_gallery/locator.dart';
import 'package:cat_gallery/store/cat_store.dart';
import 'package:cat_gallery/utils.dart';

class CatProvider extends BusyProvider {
  var _catJson;
  dynamic get catJson => _catJson;

  Future<void> loadLocalData() async {
    final catData = await locator.getAsync<CatStore>();
    _catJson = catData.allCats.fetch();

    final jsonData = json.decode(_catJson);
    jsonData['neko_list'].forEach((cat) async {
      final catId = cat['neko_id'];
      initSpecificCatData(catId, catData);
    });

    notifyListeners();
  }

  Future<void> put(String nekoId, String data) async {
    await busyRun(() async {
      final catData = await locator.getAsync<CatStore>();
      catData.put(nekoId, data);
    });
  }

  Future<String> fetch(String nekoId) async {
    final catData = await locator.getAsync<CatStore>();
    notifyListeners();
    return catData.fetch(nekoId);
  }
}