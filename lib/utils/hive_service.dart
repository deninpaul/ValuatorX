import 'dart:io';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

final VALUATION_DRAFT_BOX = "valuations";

class HiveService {
  late Box box;

  Future<void> init(String boxName) async {
    Directory dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    box = await Hive.openBox(boxName);
  }

  Future<void> put(String key, Map<String, dynamic> value) async {
    await box.put(key, value);
  }

  Map<String, dynamic> get(String key) {
    final data = box.get(key);
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {};
  }

  List<Map<String, dynamic>> getAllValues() {
    return box.values.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  List<Map<String, dynamic>> getAllDrafts() {
    return box.keys
        .whereType<String>()
        .where((key) => key.startsWith('draft_'))
        .map((key) => Map<String, dynamic>.from(box.get(key)))
        .toList();
  }

  Future<int> generateDraftId() async {
    const metadataKey = "metadata";
    int count = (box.get(metadataKey)?["count"] ?? 0) + 1;
    await box.put(metadataKey, {"count": count});
    return count;
  }

  bool contains(String key) {
    return box.containsKey(key);
  }

  Future<void> delete(String key) async {
    await box.delete(key);
  }

  Future<void> clear() async {
    await box.clear();
  }
}
