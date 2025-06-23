import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'notification_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  await NotificationService.init();

  runApp(SkeduleApp());
}

class SkeduleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Skedule',
  theme: ThemeData(
    primarySwatch: Colors.teal,
    scaffoldBackgroundColor: Colors.white,
  ),
  home: session != null ? HomeScreen() : LoginScreen(),
  );

  }
}
