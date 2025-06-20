import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

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

class SettingsService extends HiveService {
  SettingsService() : super(boxName: "settings");
}

class HiveService {
  late Box box;
  String boxName;

  HiveService({required this.boxName});

  Future<void> init() async {
    if (!kIsWeb) {
      Directory dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);
    }
    box = await Hive.openBox(boxName);
  }

  Future<void> put(String key, dynamic value) async {
    await init();
    await box.put(key, value);
  }

  Future<dynamic> get(String key) async {
    await init();
    return box.get(key);
  }

  List<Map<String, dynamic>> getAllValues() {
    return box.values.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> delete(String key) async {
    await init();
    await box.delete(key);
  }

  Future<void> clear() async {
    await init();
    await box.clear();
  }
}
