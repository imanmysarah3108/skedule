import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://ivhpkpjdgirodyjvypwd.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml2aHBrcGpkZ2lyb2R5anZ5cHdkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA2NDU1NzMsImV4cCI6MjA2NjIyMTU3M30.Tev4ouZoxt8XpWsOn_PYDx0mtLLoJsfqPRgZoEDdVYY',
    );
  }

  static Future<List<Map<String, dynamic>>> getUserClasses(String userId) async {
    try {
      final response = await client
          .from('classes')
          .select('*, subject(subject_title)')
          .eq('user_id', userId)
          .order('day')
          .order('start_time')
          .timeout(const Duration(seconds: 10));

      return response;
    } catch (e) {
      debugPrint('Error fetching classes: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getUserAssignments(String userId) async {
    try {
      final response = await client
          .from('assignments')
          .select('*, subject(subject_title)')
          .eq('user_id', userId)
          .order('due_date', ascending: true)
          .timeout(const Duration(seconds: 10));

      return response;
    } catch (e) {
      debugPrint('Error fetching assignments: $e');
      return [];
    }
  }
}