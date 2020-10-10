import 'package:cat_gallery/store/presistent_store.dart';

class UserStore with PresistentStore {
  @override
  final boxName = 'user';

  StoreProperty<String> get username => property('username');
  StoreProperty<String> get password => property('password');
  StoreProperty<bool> get savePassword => property('savePassword',defaultValue: false);
  StoreProperty<bool> get loggedIn => property('loggedIn', defaultValue: false);
}
