import 'disease.dart';

class Plant {
  final String name;
  final String image;
  final String info;
  final List<Disease> diseases;

  Plant({
    required this.name,
    required this.image,
    required this.info,
    required this.diseases,
  });
}
