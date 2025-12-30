import 'package:hive/hive.dart';

part 'weather_data.g.dart';

@HiveType(typeId: 1)
class WeatherData {
  @HiveField(0)
  final double temperature;

  @HiveField(1)
  final double humidity;

  @HiveField(2)
  final double rainfall;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final bool isManual;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.rainfall,
    required this.description,
    required this.timestamp,
    this.isManual = false,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['main']?['temp'] ?? 0.0).toDouble() - 273.15,
      humidity: (json['main']?['humidity'] ?? 0.0).toDouble(),
      rainfall: (json['rain']?['1h'] ?? 0.0).toDouble(),
      description: json['weather']?[0]?['description'] ?? 'Unknown',
      timestamp: DateTime.now(),
      isManual: false,
    );
  }

  factory WeatherData.manual({
    required double temperature,
    required double humidity,
    required double rainfall,
  }) {
    return WeatherData(
      temperature: temperature,
      humidity: humidity,
      rainfall: rainfall,
      description: 'Manually entered',
      timestamp: DateTime.now(),
      isManual: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'rainfall': rainfall,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'isManual': isManual,
    };
  }
}
