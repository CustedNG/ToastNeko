import 'dart:async';

import 'package:cat_gallery/core/provider.dart';
import 'package:cat_gallery/locator.dart';
import 'package:cat_gallery/store/cat_store.dart';
import 'package:cat_gallery/utils.dart';

class CatProvider extends BusyProvider {
  var _catJson;
  dynamic get catJson => _catJson;

  final _initialized = Completer();
  Future get initialized => _initialized.future;

  Future<void> loadLocalData() async {
    final catData = await locator.getAsync<CatStore>();
    _catJson = catData.allCats.fetch();
    notifyListeners();

    _initialized.complete(null);
  }

  Future<void> put(var data) async {
    await busyRun(() async {
      await _setData(data);
    });
  }

  Future<void> fetch(var data) async {
    unawaited(_setData(data));
    notifyListeners();
  }

  Future<void> _setData(var data) async {
    _catJson = data;
    final catData = await locator.getAsync<CatStore>();
    unawaited(catData.allCats.put(data));
  }
}