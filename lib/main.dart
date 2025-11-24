import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'core/controllers/location_controller.dart';
import 'core/controllers/theme_controller.dart';
import 'core/init/app_initializer.dart';
import 'core/services/notification_service.dart';
import 'core/services/app_lifecycle_service.dart';
import 'core/utils/continent_utils.dart';
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

      final prefs = await SharedPreferences.getInstance();

      // Get user's continent
      final userContinent = prefs.getString('user_continent');
      if (userContinent == null) {
        debugPrint('User continent not available, skipping notification');
        return Future.value(true);
      }

      // Check if app is active
      final isAppActive = await AppLifecycleService.isAppActive();

      // Get processed earthquake IDs to avoid duplicates
      final processedIds =
          prefs.getStringList('processed_earthquake_ids') ?? [];

      final recent = await apiService.getRecentEarthquakes();

      for (var earthquake in recent) {
        // Skip if already processed
        if (processedIds.contains(earthquake.id)) {
          continue;
        }

        // Detect earthquake's continent
        final earthquakeContinent = ContinentUtils.detectContinent(
          earthquake.latitude,
          earthquake.longitude,
        );

        // Determine if we should send notification
        bool shouldNotify = false;
        bool isHighPriority = false;

        if (ContinentUtils.isSameContinent(
          userContinent,
          earthquakeContinent,
        )) {
          // Same continent: always notify with high priority
          shouldNotify = true;
          isHighPriority = true;
        } else if (isAppActive) {
          // Different continent: only notify if app is active, with normal priority
          shouldNotify = true;
          isHighPriority = false;
        }

        if (shouldNotify) {
          if (isHighPriority) {
            await notificationService.showHighPriorityNotification(
              id: earthquake.hashCode,
              title: '🚨 Nearby Earthquake: ${earthquake.title}',
              body:
                  'Magnitude: ${earthquake.magnitude} • Depth: ${earthquake.depth}km • $earthquakeContinent',
            );
          } else {
            await notificationService.showNormalPriorityNotification(
              id: earthquake.hashCode,
              title: 'Earthquake Alert: ${earthquake.title}',
              body:
                  'Magnitude: ${earthquake.magnitude} • Depth: ${earthquake.depth}km • $earthquakeContinent',
            );
          }

          // Mark as processed
          processedIds.add(earthquake.id);
        }
      }

      // Keep only last 100 processed IDs to prevent list from growing indefinitely
      if (processedIds.length > 100) {
        processedIds.removeRange(0, processedIds.length - 100);
      }
      await prefs.setStringList('processed_earthquake_ids', processedIds);
    } catch (e) {
      debugPrint('Background fetch error: $e');
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.initializeApp();

  // Initialize app lifecycle service
  AppLifecycleService().init();

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
