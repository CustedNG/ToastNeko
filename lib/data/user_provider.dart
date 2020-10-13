import 'dart:async';

import 'package:cat_gallery/core/provider.dart';
import 'package:cat_gallery/locator.dart';
import 'package:cat_gallery/store/user_store.dart';
import 'package:cat_gallery/utils.dart';

class UserProvider extends BusyProvider {
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  final _initialized = Completer();
  Future get initialized => _initialized.future;

  Future<void> loadLocalData() async {
    final userData = await locator.getAsync<UserStore>();
    _loggedIn = userData.loggedIn.fetch();
    notifyListeners();

    _initialized.complete(null);
  }

  Future<void> login() async {
    await busyRun(() async {
      await _setLoginState(true);
    });
  }

  Future<void> logout() async {
    unawaited(_setLoginState(false));
    notifyListeners();
  }

  Future<void> _setLoginState(bool state) async {
    _loggedIn = state;
    final userData = await locator.getAsync<UserStore>();
    unawaited(userData.loggedIn.put(state));
  }
}