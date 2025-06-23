import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://ivhpkpjdgirodyjvypwd.supabase.co', // replace this
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml2aHBrcGpkZ2lyb2R5anZ5cHdkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA2NDU1NzMsImV4cCI6MjA2NjIyMTU3M30.Tev4ouZoxt8XpWsOn_PYDx0mtLLoJsfqPRgZoEDdVYY', // replace this
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}