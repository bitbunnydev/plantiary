import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'diary_entry.g.dart';

@HiveType(typeId: 0)
class DiaryEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String disease;

  @HiveField(3)
  double confidence;

  @HiveField(4)
  String imagePath;

  @HiveField(5)
  String notes;

  @HiveField(6)
  String folder;

  @HiveField(7)
  DateTime date;

  @HiveField(8)
  Map<String, double> allConfidences;

  @HiveField(9)
  List<String> imagePaths;

  DiaryEntry({
    required this.id,
    required this.name,
    required this.disease,
    required this.confidence,
    required this.imagePath,
    required this.notes,
    required this.folder,
    required this.date,
    required this.allConfidences,
    List<String>? imagePaths,
  }) : imagePaths = imagePaths ?? [imagePath];

  String get dateFormatted {
    return DateFormat('dd MMM yyyy • hh:mm a').format(date);
  }

  String get primaryImage => imagePaths.isNotEmpty ? imagePaths.first : imagePath;
  
  int get imageCount => imagePaths.length;
}
