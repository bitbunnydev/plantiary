import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  WeatherData? _weatherData;
  bool _isLoading = false;
  bool _isOnline = false;
  String _riskLevel = 'Low';
  String _advice = '';

  // State for selectors
  String _selectedCrop = 'Paddy';
  final List<String> _crops = [
    'Banana',
    'Corn',
    'Paddy',
    'Pepper',
    'Strawberry',
  ];

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() => _isLoading = true);
    _isOnline = await WeatherService.isOnline();
    final position = await WeatherService.getCurrentLocation();

    WeatherData? weather;
    if (position != null) {
      weather = await WeatherService.getWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } else {
      weather = await WeatherService.getWeather(cityName: 'Kuala Lumpur');
    }

    if (weather != null) {
      setState(() {
        _weatherData = weather;
        _calculateRisk();
      });
    }
    setState(() => _isLoading = false);
  }

  void _calculateRisk() {
    if (_weatherData == null) return;
    setState(() {
      _riskLevel = WeatherService.getRiskLevel(
        weather: _weatherData!,
        cropType: _selectedCrop,
        growthStage: 'Growing',
      );
      _advice = WeatherService.getFarmingAdvice(
        weather: _weatherData!,
        riskLevel: _riskLevel,
        cropType: _selectedCrop,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAF9),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Weather & Risk',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isOnline ? Icons.cloud_done : Icons.cloud_off,
              color: _isOnline ? Colors.green : Colors.orange,
            ),
            onPressed: _loadWeather,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : RefreshIndicator(
              onRefresh: _loadWeather,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        "Select Crop",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildCropSelector(),
                    const SizedBox(height: 24),
                    if (_weatherData != null) ...[
                      _buildWeatherCard(),
                      const SizedBox(height: 20),
                      _buildRiskAssessmentCard(),
                      const SizedBox(height: 20),
                      _buildAdviceCard(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCropSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: _crops.map((crop) {
          bool isSelected = _selectedCrop == crop;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(crop),
              selected: isSelected,
              selectedColor: Colors.blue.shade100,
              labelStyle: GoogleFonts.poppins(
                color: isSelected ? Colors.blue.shade800 : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _selectedCrop = crop;
                    _calculateRisk();
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade200.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _weatherMetric(
                  Icons.thermostat,
                  '${_weatherData!.temperature.toStringAsFixed(1)}°C',
                  'Temp',
                ),
                _weatherMetric(
                  Icons.water_drop,
                  '${_weatherData!.humidity.toStringAsFixed(0)}%',
                  'Humidity',
                ),
                _weatherMetric(
                  Icons.umbrella,
                  '${_weatherData!.rainfall.toStringAsFixed(1)}mm',
                  'Rain',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, color: Colors.white70, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Updated: ${_formatTime(_weatherData!.timestamp)}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _weatherMetric(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildRiskAssessmentCard() {
    Color riskColor = _riskLevel == 'High'
        ? Colors.red
        : (_riskLevel == 'Medium' ? Colors.orange : Colors.green);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: riskColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: riskColor, size: 30),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Risk Level',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  _riskLevel,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: riskColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Farming Advice',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _advice,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }
}
