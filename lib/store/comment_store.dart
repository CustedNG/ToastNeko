import 'presistent_store.dart';

class CommentStore with PresistentStore<String> {
  @override
  final boxName = 'comment';

  void put(String id, dynamic catJson) {
    if(!catJson is String)catJson = catJson.toString();
    this.box.put(id, catJson);
  }

  Map<String, dynamic> fetch(String id) {
    final data = this.box.get(id);
    if (data == null) return null;

    return data as Map<String, dynamic>;
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