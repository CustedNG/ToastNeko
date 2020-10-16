import 'dart:async';
import 'dart:convert';

import 'package:cat_gallery/core/provider.dart';
import 'package:cat_gallery/locator.dart';
import 'package:cat_gallery/store/cat_store.dart';
import 'package:cat_gallery/utils.dart';

class CatProvider extends BusyProvider {
  CatStore _catStore;
  CatStore get catStore => _catStore;

  Future<void> loadData() async {
    final catData = await locator.getAsync<CatStore>();
    _catStore = catData;

    updateData();
    notifyListeners();
  }

  void updateData([String nekoId]) async {
    if(nekoId != null){
      initSpecificCatData(nekoId, _catStore);
      refreshData();
      return;
    }

    final jsonData = json.decode(_catStore.allCats.fetch());
    jsonData['neko_list'].forEach((cat) async {
      final catId = cat['neko_id'];
      initSpecificCatData(catId, _catStore);
    });

    refreshData();
  }

  void refreshData() async {
    _catStore = await locator.getAsync<CatStore>();
    notifyListeners();
  }

  Future<void> put(String nekoId, String data) async {
    await busyRun(() async {
      final catData = await locator.getAsync<CatStore>();
      catData.put(nekoId, data);
      _catStore = catData;
    });
  }

  Future<String> fetch(String nekoId) async {
    final catData = await locator.getAsync<CatStore>();
    notifyListeners();
    return catData.fetch(nekoId);
  }
}