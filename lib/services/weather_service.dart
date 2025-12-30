import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import '../models/weather_data.dart';

class WeatherService {
  static const String _apiKey = '548abf876c40136fac1a439f0b222ae4';
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';
  static const String _cacheBoxName = 'weather_cache';

  static Future<void> init() async {
    if (!Hive.isBoxOpen(_cacheBoxName)) {
      await Hive.openBox<WeatherData>(_cacheBoxName);
    }
  }

  static Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.first != ConnectivityResult.none;
  }

  static Future<WeatherData?> getWeather({
    double? latitude,
    double? longitude,
    String? cityName,
  }) async {
    try {
      final online = await isOnline();

      if (online) {
        final weatherData = await _fetchWeatherFromApi(
          latitude: latitude,
          longitude: longitude,
          cityName: cityName,
        );
        if (weatherData != null) {
          return weatherData;
        }
      }
      
      final cached = _getCachedWeather();
      if (cached != null) {
        return cached;
      }
      
      return _getDemoWeather();
    } catch (e) {
      final cached = _getCachedWeather();
      if (cached != null) {
        return cached;
      }
      return _getDemoWeather();
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
        url = '$_baseUrl?lat=$latitude&lon=$longitude&appid=$_apiKey';
      } else if (cityName != null) {
        url = '$_baseUrl?q=$cityName&appid=$_apiKey';
      } else {
        return null;
      }

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final weatherData = WeatherData.fromJson(data);
        await _cacheWeather(weatherData);
        return weatherData;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> _cacheWeather(WeatherData data) async {
    final box = await Hive.openBox<WeatherData>(_cacheBoxName);
    await box.put('latest', data);
  }

  static WeatherData? _getCachedWeather() {
    final box = Hive.box<WeatherData>(_cacheBoxName);
    return box.get('latest');
  }

  static Future<void> saveManualWeather(WeatherData data) async {
    await _cacheWeather(data);
  }

  static WeatherData _getDemoWeather() {
    return WeatherData(
      temperature: 26.5,
      humidity: 65.0,
      rainfall: 2.5,
      description: 'Demo weather data - Partly cloudy',
      timestamp: DateTime.now(),
      isManual: false,
    );
  }

  static String getRiskLevel({
    required WeatherData weather,
    required String cropType,
    required String growthStage,
  }) {
    int riskScore = 0;

    if (weather.humidity > 80) {
      riskScore += 3;
    } else if (weather.humidity > 60) {
      riskScore += 2;
    } else if (weather.humidity > 40) {
      riskScore += 1;
    }

    if (weather.temperature > 30) {
      riskScore += 2;
    } else if (weather.temperature > 25) {
      riskScore += 1;
    } else if (weather.temperature < 10) {
      riskScore += 2;
    }

    if (weather.rainfall > 10) {
      riskScore += 3;
    } else if (weather.rainfall > 5) {
      riskScore += 2;
    } else if (weather.rainfall > 2) {
      riskScore += 1;
    }

    if (growthStage.toLowerCase().contains('flowering') ||
        growthStage.toLowerCase().contains('fruiting')) {
      riskScore += 1;
    }

    if (riskScore >= 7) {
      return 'High';
    } else if (riskScore >= 4) {
      return 'Medium';
    } else {
      return 'Low';
    }
  }

  static String getFarmingAdvice({
    required WeatherData weather,
    required String riskLevel,
  }) {
    if (riskLevel == 'High') {
      if (weather.humidity > 80) {
        return 'High humidity detected. Avoid spraying fungicides. Risk of fungal diseases is very high. Ensure good air circulation.';
      } else if (weather.rainfall > 10) {
        return 'Heavy rainfall expected. Postpone any spraying activities. Check for waterlogging and drainage issues.';
      } else if (weather.temperature > 30) {
        return 'High temperature alert. Ensure adequate irrigation. Avoid midday spraying to prevent leaf burn.';
      }
      return 'High disease risk. Monitor crops closely and take preventive measures.';
    } else if (riskLevel == 'Medium') {
      if (weather.humidity > 60) {
        return 'Moderate humidity levels. Good time for preventive spraying if no rain is expected in next 24 hours.';
      } else if (weather.rainfall > 5) {
        return 'Moderate rainfall expected. Plan spraying activities carefully. Wait for dry conditions.';
      }
      return 'Moderate risk. Regular monitoring recommended. Consider preventive measures.';
    } else {
      if (weather.humidity < 40 && weather.rainfall < 2) {
        return 'Favorable conditions for spraying. Low disease risk. Good time for field operations.';
      }
      return 'Low disease risk. Continue regular monitoring and maintenance.';
    }
  }
}
