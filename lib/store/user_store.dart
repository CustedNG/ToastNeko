import 'package:cat_gallery/store/presistent_store.dart';

class UserStore with PresistentStore {
  @override
  final boxName = 'user';

  StoreProperty<String> get username => property('username');
  StoreProperty<String> get password => property('password');
  StoreProperty<String> get openId => property('openId');
  StoreProperty<String> get nick => property('nick');
  StoreProperty<String> get lastCommentTime => property('lastCommentTime');
  StoreProperty<String> get lastFeedbackTime => property('lastFeedbackTime');
  StoreProperty<String> get msg => property('msg');
  StoreProperty<bool> get savePassword => property('savePassword', defaultValue: false);
  StoreProperty<bool> get loggedIn => property('loggedIn', defaultValue: false);
}
