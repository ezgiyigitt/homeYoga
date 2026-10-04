/// Supabase project credentials.
///
/// Replace these with your actual values:
/// 1. https://app.supabase.com → Your Project → Settings → API
/// 2. Copy "Project URL" and "anon public" key
///
/// In production, inject via --dart-define flags instead of hardcoding.
abstract class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://qcxbqitzfdtzukytqira.supabase.co';

  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFjeGJxaXR6ZmR0enVreXRxaXJhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTExMDU2MjAsImV4cCI6MjEwNjY4MTYyMH0.P6KCabT3JVNEc7zXrRozZbCbDEMgM7Tm1futK8OjxMs';

  /// True when real credentials are configured.
  static bool get isConfigured =>
      url != 'https://placeholder.supabase.co' &&
      anonKey != 'placeholder-anon-key';
}
