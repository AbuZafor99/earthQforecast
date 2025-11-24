import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'core/controllers/location_controller.dart';
import 'core/controllers/theme_controller.dart';
import 'core/init/app_initializer.dart';
import 'core/services/notification_service.dart';
import 'core/widgets/custom_bottom_nav_bar.dart';
import 'features/earthquake/data/sources/earthquake_api.dart';
import 'features/earthquake/presentation/controllers/earthquake_controller.dart';
import 'features/earthquake/presentation/screens/home_screen.dart';
import 'features/earthquake/presentation/screens/map_screen.dart';
import 'features/earthquake/presentation/screens/news_screen.dart';
import 'features/splash/splash_screen.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final apiService = ApiService();
      final notificationService = NotificationService();
      await notificationService.init();

      final recent = await apiService.getRecentEarthquakes();
      if (recent.isNotEmpty) {
        final latest = recent.first;
        final prefs = await SharedPreferences.getInstance();
        final lastId = prefs.getString('last_earthquake_id');

        if (lastId != latest.id) {
          await notificationService.showNotification(
            id: latest.hashCode,
            title: 'New Earthquake: ${latest.title}',
            body: 'Magnitude: ${latest.magnitude}, Depth: ${latest.depth}km',
          );
          await prefs.setString('last_earthquake_id', latest.id);
        }
      }
    } catch (e) {
      debugPrint('Background fetch error: $e');
    }
    return Future.value(true);
  });
}

void main() async {
  await AppInitializer.initializeApp();
  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
    "1",
    "fetchEarthquakes",
    frequency: const Duration(minutes: 15), // Minimum 15 min on Android
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Earthquake Alert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFFEF4444),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFEF4444),
          secondary: Color(0xFF3B82F6),
          surface: Color(0xFF1E293B),
        ),
      ),
      themeMode: ThemeMode.system, // Will be controlled by ThemeController
      initialBinding: InitialBinding(),
      home: const SplashScreen(),
    );
  }
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController());
    Get.put(LocationController());
    Get.put(EarthquakeController());
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MapScreen(),
    const NewsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          IndexedStack(index: _currentIndex, children: _screens),
          // Floating bottom nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
