import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'models/diary_entry.dart';
import 'models/weather_data.dart';
import 'services/diary_service.dart';
import 'services/weather_service.dart';
import 'services/navigation_service.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  await Hive.initFlutter();

  Hive.registerAdapter(DiaryEntryAdapter());
  Hive.registerAdapter(WeatherDataAdapter());
  
  await DiaryService.init();
  await WeatherService.init();

  await Hive.openBox('settings');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Plant Diary',
      theme: _darkMode ? AppTheme.dark : AppTheme.light,
      home: SplashScreen(
        darkModeCallback: () {
          setState(() => _darkMode = !_darkMode);
        },
      ),
    );
  }
}
