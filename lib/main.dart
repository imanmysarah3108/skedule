import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'interfaces/home_screen.dart';
import 'interfaces/login_screen.dart'; // Assuming you have a login_screen.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // Replace with your actual Supabase URL and anonymous key
  await Supabase.initialize(
    url: 'https://ivhpkpjdgirodyjvypwd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml2aHBrcGpkZ2lyb2R5anZ5cHdkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA2NDU1NzMsImV4cCI6MjA2NjIyMTU3M30.Tev4ouZoxt8XpWsOn_PYDx0mtLLoJsfqPRgZoEDdVYY',
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Listen for authentication changes and navigate accordingly
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        // User just signed in, navigate to home
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
      } else if (event == AuthChangeEvent.signedOut) {
        // User just signed out, navigate to login
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skedule App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Determine the initial screen based on current session
      home: Supabase.instance.client.auth.currentUser == null
          ? const LoginScreen()
          : HomeScreen(),
    );
  }
}