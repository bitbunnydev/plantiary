import 'package:hive/hive.dart';
import '../models/diary_entry.dart';

class DiaryService {
  static const String diaryBoxName = 'diaryBox';
  static const String foldersBoxName = 'foldersBox';

  static Future<void> init() async {
    if (!Hive.isBoxOpen(diaryBoxName))
      await Hive.openBox<DiaryEntry>(diaryBoxName);
    if (!Hive.isBoxOpen(foldersBoxName))
      await Hive.openBox<String>(foldersBoxName);
  }

  static Box<DiaryEntry> get _diaryBox => Hive.box<DiaryEntry>(diaryBoxName);

  static Future<void> addEntry(DiaryEntry entry) async {
    await _diaryBox.put(entry.id, entry);
  }

  static List<DiaryEntry> getAllEntries() {
    return _diaryBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  static List<DiaryEntry> getEntriesByFolder(String folderName) {
    return _diaryBox.values
        .where((e) => e.folder == folderName)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  static DiaryEntry? getEntry(String id) => _diaryBox.get(id);

  static Future<void> deleteEntry(String id) async {
    await _diaryBox.delete(id);
  }

  static Future<void> updateEntry(DiaryEntry entry) async {
    await entry.save();
  }

  static Box<String> get _foldersBox => Hive.box<String>(foldersBoxName);

  static List<String> getAllFolders() {
    final folders = _foldersBox.values.toList();
    folders.sort();
    return folders;
  }

  static Future<void> createFolder(String folderName) async {
    if (folderName.trim().isEmpty) return;
    if (_foldersBox.containsKey(folderName)) return;
    await _foldersBox.put(folderName, folderName);
  }

  static Future<void> renameFolder(String oldName, String newName) async {
    if (!_foldersBox.containsKey(oldName)) return;
    if (newName.trim().isEmpty) return;
    if (_foldersBox.containsKey(newName)) return;

    await _foldersBox.put(newName, newName);
    await _foldersBox.delete(oldName);

    for (var entry in _diaryBox.values) {
      if (entry.folder == oldName) {
        entry.folder = newName;
        await entry.save();
      }
    }
  }

  static Future<void> deleteFolder(
    String folderName, {
    String migrateTo = '',
  }) async {
    if (!_foldersBox.containsKey(folderName)) return;
    await _foldersBox.delete(folderName);

    for (var entry in _diaryBox.values) {
      if (entry.folder == folderName) {
        entry.folder = migrateTo;
        await entry.save();
      }
    }
  }
}
