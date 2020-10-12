import 'presistent_store.dart';

class CatStore with PresistentStore<String> {
  @override
  final boxName = 'cat';

  StoreProperty<String> get allCats => property('all_cats');

  void putAll(dynamic catJson) {
    if(!(catJson is String))catJson = catJson.toString();
    if(this.box.isOpen)this.box.put('all_cat', catJson);
  }

  void put(String id, String catJson) {
    this.box.put(id, catJson);
  }

  String fetch(String id) {
    return this.box.get(id);
  }
}