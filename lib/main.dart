import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skedule/components/nav_bar.dart';
import 'package:skedule/interfaces/assignment_screen.dart';
import 'package:skedule/interfaces/class_schedule.dart';
import 'package:skedule/interfaces/home_screen.dart';
import 'package:skedule/interfaces/settings.dart';
import 'package:skedule/notification_service.dart';
import 'package:skedule/performance%20_helper.dart';
import 'package:skedule/providers.dart';
import 'package:skedule/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable debug prints in release mode
  if (!kDebugMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // Initialize services with error handling
  try {
    // Initialize Supabase first
    await SupabaseService.initialize();
    
    // Initialize other services in parallel
    await Future.wait([
      NotificationService.init().catchError((e) {
        debugPrint('Notification init error: $e');
      }),
    ]);
  } catch (e) {
    debugPrint("App initialization failed: $e");
    runApp(const ErrorApp());
    return;
  }

  // Run app with performance optimizations
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FontProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Skedule',
      theme: themeProvider.isDarkMode ? _buildDarkTheme() : _buildLightTheme(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          PerformanceHelper.logPerformance('Frame rendered');
        });
        return child!;
      },
      home: const MainWrapper(),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                'App Initialization Failed',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              const Text('Please restart the application'),
            ],
          ),
        ),
      ),
    );
  }
}

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  static final PageStorageBucket _bucket = PageStorageBucket();

  final List<Widget> _pages = [
    PageStorage(child: HomeScreen(), bucket: _bucket),
    PageStorage(child: ScheduleScreen(), bucket: _bucket),
    PageStorage(child: AssignmentsScreen(), bucket: _bucket),
    PageStorage(child: SettingsScreen(), bucket: _bucket),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: FuturisticNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}