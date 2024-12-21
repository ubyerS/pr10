import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://lccmlzysstrvkmnlboup.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxjY21senlzc3Rydmttbmxib3VwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQzODk4NzgsImV4cCI6MjA0OTk2NTg3OH0.ya46YHQgsuz-f9SKvHgn8N9Ir3Ru4b54dfVr8YykAu4';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
