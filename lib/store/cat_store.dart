import 'package:cat_gallery/data/ge.dart';
import 'presistent_store.dart';

class CatStore with PresistentStore<String> {
  @override
  final boxName = 'cat';

  void put(dynamic catJson) {
    if(!catJson is String)catJson = catJson.toString();
    this.box.put('cat_data', catJson);
  }

  Map<String, dynamic> fetch(String id) {
    final data = this.box.get('cat_data');
    if (data == null) return null;

    (data as List<Map<String, dynamic>>)
        .forEach((cat){
          if(cat[Strs.keyCatId] == id)return cat;
        });
    return null;
  }

  List<Map<String, dynamic>> fetchAll() {
    final length = this.box.length;
    List<Map<String, dynamic>> catJson;
    for(int i = 0; i < length; i++){
      catJson.add(this.box.getAt(i).toString() as Map<String, dynamic>);
    }
    return catJson;
  }
}