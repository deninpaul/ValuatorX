import 'package:valuatorx/services/hive_service.dart';

class DraftService extends HiveService {
  DraftService({required super.boxName});

  Future<Map<String, dynamic>> getDraft(String key) async {
    await init();
    final data = box.get(key);
    return data is Map ? Map<String, dynamic>.from(data) : {};
  }

  Future<List<Map<String, dynamic>>> getAllDrafts() async {
    await init();
    return box.keys
        .whereType<String>()
        .where((key) => key.startsWith('draft_'))
        .map((key) => Map<String, dynamic>.from(box.get(key)))
        .toList();
  }

  Future<int> generateDraftId() async {
    await init();
    final value = box.get("count");
    int count = (value is int ? value : 0) + 1;
    await box.put("count", count);
    return count;
  }
}
