import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_data.dart';

class WeatherService {
  static String get _apiKey => dotenv.env['WEATHER_API_KEY'] ?? '';
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';
  static const String _cacheBoxName = 'weather_cache';

  // ================= INIT =================
  static Future<void> init() async {
    if (!Hive.isBoxOpen(_cacheBoxName)) {
      await Hive.openBox<WeatherData>(_cacheBoxName);
    }
  }

  // ================= CONNECTIVITY =================
  static Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // ================= LOCATION =================
  static Future<Position?> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 100,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  // ================= WEATHER =================
  static Future<WeatherData?> getWeather({
    double? latitude,
    double? longitude,
    String? cityName,
  }) async {
    try {
      if (await isOnline()) {
        final weather = await _fetchWeatherFromApi(
          latitude: latitude,
          longitude: longitude,
          cityName: cityName,
        );
        if (weather != null) return weather;
      }
      return _getCachedWeather() ?? _getDemoWeather();
    } catch (_) {
      return _getCachedWeather() ?? _getDemoWeather();
    }
  }

  static Future<WeatherData?> _fetchWeatherFromApi({
    double? latitude,
    double? longitude,
    String? cityName,
  }) async {
    try {
      String url;
      if (latitude != null && longitude != null) {
        url =
            '$_baseUrl?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric';
      } else if (cityName != null) {
        url = '$_baseUrl?q=$cityName&appid=$_apiKey&units=metric';
      } else {
        return null;
      }

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final double rainfall =
            data['rain'] != null && data['rain']['1h'] != null
            ? (data['rain']['1h'] as num).toDouble()
            : 0.0;

        final weatherData = WeatherData(
          temperature: (data['main']['temp'] as num).toDouble(),
          humidity: (data['main']['humidity'] as num).toDouble(),
          rainfall: rainfall,
          description: data['weather'][0]['description'],
          timestamp: DateTime.now(),
        );

        await _cacheWeather(weatherData);
        return weatherData;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ================= CACHE =================
  static Future<void> _cacheWeather(WeatherData data) async {
    final box = Hive.box<WeatherData>(_cacheBoxName);
    await box.put('latest', data);
  }

  static WeatherData? _getCachedWeather() {
    final box = Hive.box<WeatherData>(_cacheBoxName);
    return box.get('latest');
  }

  static WeatherData _getDemoWeather() {
    return WeatherData(
      temperature: 26.0,
      humidity: 70.0,
      rainfall: 1.0,
      description: 'Demo weather data',
      timestamp: DateTime.now(),
    );
  }

  // ================= RISK LEVEL (ALL CROPS) =================
  static String getRiskLevel({
    required WeatherData weather,
    required String cropType,
    required String growthStage,
  }) {
    double riskScore = 0;
    final crop = cropType.toLowerCase();
    final stage = growthStage.toLowerCase();

    // ---------- HUMIDITY ----------
    if (weather.humidity >= 85) {
      if (crop == 'strawberry' || crop == 'pepper') {
        riskScore += 4;
      } else if (crop == 'paddy' || crop == 'banana') {
        riskScore += 3.5;
      } else if (crop == 'corn') {
        riskScore += 2.5;
      }
    } else if (weather.humidity >= 70) {
      riskScore += 2;
    }

    // ---------- TEMPERATURE ----------
    if (crop == 'paddy') {
      if (weather.temperature < 18 || weather.temperature > 35) riskScore += 2;
    }
    if (crop == 'banana') {
      if (weather.temperature < 15 || weather.temperature > 38) riskScore += 3;
    }
    if (crop == 'corn') {
      // NEW: Corn optimal range 20–30°C → no added risk
      if (weather.temperature < 20 || weather.temperature > 30)
        riskScore += 1.5;
    }
    if (crop == 'pepper') {
      if (weather.temperature > 32)
        riskScore += 3;
      else if (weather.temperature < 15)
        riskScore += 2;
    }
    if (crop == 'strawberry') {
      if (weather.temperature > 30 || weather.temperature < 10) riskScore += 3;
    }

    // ---------- RAINFALL ----------
    if (weather.rainfall > 15) {
      if (crop == 'strawberry' || crop == 'pepper')
        riskScore += 4;
      else
        riskScore += 2.5;
    } else if (weather.rainfall > 5) {
      riskScore += 1.5;
    }

    if (crop == 'paddy' && weather.rainfall < 1) riskScore += 0.5;
    if (crop == 'corn' && weather.rainfall < 1)
      riskScore += 1; // less severe now

    // ---------- GROWTH STAGE ----------
    if (stage.contains('flowering') || stage.contains('fruiting'))
      riskScore += 1.5;
    else if (stage.contains('seedling'))
      riskScore += 1;

    // ---------- FINAL LEVEL ----------
    if (riskScore >= 8) return 'High';
    if (riskScore >= 4) return 'Medium';
    return 'Low';
  }

  // ================= FARMING ADVICE =================
  static String getFarmingAdvice({
    required WeatherData weather,
    required String riskLevel,
    required String cropType,
  }) {
    final crop = cropType.toLowerCase();

    if (riskLevel == 'High') {
      if (weather.humidity > 80) {
        if (crop == 'strawberry') {
          return 'Very high risk of gray mold. Improve ventilation and avoid overhead watering.';
        }
        if (crop == 'pepper') {
          return 'High humidity may cause fungal leaf and fruit diseases. Monitor closely.';
        }
        if (crop == 'paddy') {
          return 'High humidity increases risk of rice blast and sheath blight.';
        }
      }

      if (weather.rainfall > 15) {
        return 'Heavy rainfall detected. Improve drainage and delay spraying for $cropType.';
      }

      return 'High-risk conditions detected. Close monitoring of $cropType is required.';
    }

    if (riskLevel == 'Medium') {
      return 'Moderate risk detected. Regular inspection of $cropType is recommended.';
    }

    return 'Weather conditions are favorable for $cropType. Disease risk is low.';
  }
}
