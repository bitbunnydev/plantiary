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
  String _riskLevel = 'Unknown';
  String _advice = '';

  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();
  final TextEditingController _rainfallController = TextEditingController();
  final TextEditingController _cropTypeController = TextEditingController(text: 'General');
  final TextEditingController _growthStageController = TextEditingController(text: 'Growing');

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _humidityController.dispose();
    _rainfallController.dispose();
    _cropTypeController.dispose();
    _growthStageController.dispose();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    setState(() => _isLoading = true);

    _isOnline = await WeatherService.isOnline();
    final weather = await WeatherService.getWeather(cityName: 'London');

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

    _riskLevel = WeatherService.getRiskLevel(
      weather: _weatherData!,
      cropType: _cropTypeController.text,
      growthStage: _growthStageController.text,
    );

    _advice = WeatherService.getFarmingAdvice(
      weather: _weatherData!,
      riskLevel: _riskLevel,
    );
  }

  Future<void> _saveManualWeather() async {
    final temp = double.tryParse(_temperatureController.text);
    final humidity = double.tryParse(_humidityController.text);
    final rainfall = double.tryParse(_rainfallController.text);

    if (temp == null || humidity == null || rainfall == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers')),
      );
      return;
    }

    final manualWeather = WeatherData.manual(
      temperature: temp,
      humidity: humidity,
      rainfall: rainfall,
    );

    await WeatherService.saveManualWeather(manualWeather);

    setState(() {
      _weatherData = manualWeather;
      _calculateRisk();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manual weather data saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAF9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Weather & Risk Assessment',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
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
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  if (_weatherData != null) ...[
                    _buildWeatherCard(),
                    const SizedBox(height: 16),
                    _buildRiskAssessmentCard(),
                    const SizedBox(height: 16),
                    _buildAdviceCard(),
                  ],
                  const SizedBox(height: 16),
                  _buildManualInputCard(),
                  const SizedBox(height: 16),
                  _buildCropInfoCard(),
                  const SizedBox(height: 32),
                ],
              ),
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
              color: Colors.blue.shade300.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Weather',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _weatherData!.isManual ? 'Manual' : 'Live',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _weatherMetric(
                  Icons.thermostat,
                  '${_weatherData!.temperature.toStringAsFixed(1)}°C',
                  'Temperature',
                ),
                _weatherMetric(
                  Icons.water_drop,
                  '${_weatherData!.humidity.toStringAsFixed(0)}%',
                  'Humidity',
                ),
                _weatherMetric(
                  Icons.grain,
                  '${_weatherData!.rainfall.toStringAsFixed(1)}mm',
                  'Rainfall',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _weatherData!.description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Updated: ${_formatTime(_weatherData!.timestamp)}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weatherMetric(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildRiskAssessmentCard() {
    Color riskColor;
    IconData riskIcon;

    switch (_riskLevel) {
      case 'High':
        riskColor = Colors.red;
        riskIcon = Icons.warning_rounded;
        break;
      case 'Medium':
        riskColor = Colors.orange;
        riskIcon = Icons.info_rounded;
        break;
      default:
        riskColor = Colors.green;
        riskIcon = Icons.check_circle_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: riskColor.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: riskColor.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(riskIcon, color: riskColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Disease Risk Level',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        _riskLevel,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: riskColor,
                        ),
                      ),
                    ],
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_rounded, color: Colors.amber.shade600, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Farming Advice',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _advice,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualInputCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_rounded, color: Colors.purple.shade600, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Manual Weather Input',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(_temperatureController, 'Temperature (°C)', Icons.thermostat),
            const SizedBox(height: 12),
            _buildTextField(_humidityController, 'Humidity (%)', Icons.water_drop),
            const SizedBox(height: 12),
            _buildTextField(_rainfallController, 'Rainfall (mm)', Icons.grain),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveManualWeather,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Save & Calculate Risk',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.agriculture_rounded, color: Colors.green.shade600, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Crop Information',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(_cropTypeController, 'Crop Type', Icons.eco),
            const SizedBox(height: 12),
            _buildTextField(_growthStageController, 'Growth Stage', Icons.trending_up),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _calculateRisk();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Update Risk Assessment',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.green.shade600, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
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
