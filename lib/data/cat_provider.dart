import 'dart:async';

import 'package:cat_gallery/core/provider.dart';
import 'package:cat_gallery/locator.dart';
import 'package:cat_gallery/store/cat_store.dart';

class CatProvider extends BusyProvider {
  var _catJson;
  dynamic get catJson => _catJson;

  Map<String, String> _catDataMap;
  Map<String, String> get catDataMap => _catDataMap;

  final _initialized = Completer();
  Future get initialized => _initialized.future;

  Future<void> loadLocalData() async {
    final catData = await locator.getAsync<CatStore>();
    _catJson = catData.allCats.fetch();
    notifyListeners();

    _initialized.complete(null);
  }

  Future<void> put(String nekoId, String data) async {
    await busyRun(() async {
      final catData = await locator.getAsync<CatStore>();
      catData.put(nekoId, data);
    });
  }

  Future<void> fetch(String nekoId) async {
    final catData = await locator.getAsync<CatStore>();
    catData.fetch(nekoId);
    notifyListeners();
  }
}