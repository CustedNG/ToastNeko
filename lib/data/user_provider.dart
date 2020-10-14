import 'dart:async';

import 'package:cat_gallery/core/provider.dart';
import 'package:cat_gallery/locator.dart';
import 'package:cat_gallery/store/user_store.dart';
import 'package:cat_gallery/utils.dart';

class UserProvider extends BusyProvider {
  bool _loggedIn = false;
  String _nick;
  String _lastCommentTime;
  String _openId;

  bool get loggedIn => _loggedIn;
  String get nick => _nick;
  String get lastCommentTime => _lastCommentTime;
  String get openId => _openId;

  final _initialized = Completer();
  Future get initialized => _initialized.future;

  Future<void> loadLocalData() async {
    final userData = await locator.getAsync<UserStore>();
    _loggedIn = userData.loggedIn.fetch();
    _nick = userData.nick.fetch();
    _lastCommentTime = userData.lastCommentTime.fetch();
    _openId = userData.openId.fetch();
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

  Future<void> setNick(String nickName) async {
    _nick = nickName;
    final userData = await locator.getAsync<UserStore>();
    unawaited(userData.nick.put(nickName));
  }

  Future<void> _setLoginState(bool state) async {
    _loggedIn = state;
    final userData = await locator.getAsync<UserStore>();
    unawaited(userData.loggedIn.put(state));
  }
}