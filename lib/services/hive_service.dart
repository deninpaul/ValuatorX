import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

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
