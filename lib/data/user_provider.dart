import 'dart:async';

import 'package:cat_gallery/core/provider.dart';
import 'package:cat_gallery/locator.dart';
import 'package:cat_gallery/store/user_store.dart';
import 'package:cat_gallery/utils.dart';

class UserProvider extends BusyProvider {
  bool _loggedIn = false;
  bool _isAdmin = false;
  String _nick;
  String _lastCommentTime;
  String _lastFeedbackTime;
  String _openId;
  String _msg;
  String _pwd;
  String _cid;

  bool get loggedIn => _loggedIn;
  bool get isAdmin => _isAdmin;
  String get nick => _nick;
  String get lastCommentTime => _lastCommentTime;
  String get lastFeedbackTime => _lastFeedbackTime;
  String get openId => _openId;
  String get msg => _msg;
  String get pwd => _pwd;
  String get cid => _cid;

  final _initialized = Completer();
  Future get initialized => _initialized.future;

  Future<void> loadLocalData() async {
    final userData = await locator.getAsync<UserStore>();
    _loggedIn = userData.loggedIn.fetch();
    _nick = userData.nick.fetch();
    _lastCommentTime = userData.lastCommentTime.fetch();
    _lastFeedbackTime = userData.lastFeedbackTime.fetch();
    _openId = userData.openId.fetch();
    _msg = userData.msg.fetch();
    _pwd = userData.password.fetch();
    _cid = userData.username.fetch();
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

  void setUserName(String userName) async{
    _cid = userName;
    final userData = await locator.getAsync<UserStore>();
    unawaited(userData.username.put(userName));
  }

  void setPassword(String password) async{
    _pwd = password;
    final userData = await locator.getAsync<UserStore>();
    unawaited(userData.password.put(password));
  }
  
  void setOpenId(String openId) async{
    _openId = openId;
    final userData = await locator.getAsync<UserStore>();
    unawaited(userData.openId.put(openId));
  }

  Future<void> setLastCommentTime(String lastTime) async {
    _lastCommentTime = lastTime;
    final userData = await locator.getAsync<UserStore>();
    unawaited(userData.lastCommentTime.put(lastTime));
  }

  Future<void> setLastFeedbackTime(String lastTime) async {
    _lastFeedbackTime = lastTime;
    final userData = await locator.getAsync<UserStore>();
    unawaited(userData.lastFeedbackTime.put(lastTime));
  }

  Future<void> setNick(String nickName) async {
    _nick = nickName;
    final userData = await locator.getAsync<UserStore>();
    unawaited(userData.nick.put(nickName));
  }

  Future<void> setMsg(String msg) async {
    _msg = msg;
    final userData = await locator.getAsync<UserStore>();
    unawaited(userData.msg.put(msg));
  }

  Future<void> clearMsg() async {
    _msg = '{"msg_list":[]}';
    final userData = await locator.getAsync<UserStore>();
    unawaited(userData.msg.put('{"msg_list":[]}'));
  }

  Future<void> setIsAdmin(bool isAdmin) async {
    _isAdmin = isAdmin;
    final userData = await locator.getAsync<UserStore>();
    unawaited(userData.isAdmin.put(isAdmin));
  }

  Future<void> _setLoginState(bool state) async {
    _loggedIn = state;
    final userData = await locator.getAsync<UserStore>();
    unawaited(userData.loggedIn.put(state));
  }
}