import 'dart:async';

import 'package:flutter/widgets.dart';

class ProviderBase with ChangeNotifier {
  void setState(void callback()) {
    callback();
    notifyListeners();
  }
}

class BusyProvider extends ProviderBase {
  bool _isBusy = false;
  bool get isBusy => _isBusy;

  setBusyState([bool isBusy = true]) {
    _isBusy = isBusy;
    notifyListeners();
  }

  FutureOr<T> busyRun<T>(FutureOr<T> func()) async {
    setBusyState(true);
    try {
      return await Future.sync(func);
    } catch (e) {
      rethrow;
    } finally {
      setBusyState(false);
    }
  }
}
