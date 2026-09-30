/// Supabase project credentials.
///
/// Replace these with your actual values:
/// 1. https://app.supabase.com → Your Project → Settings → API
/// 2. Copy "Project URL" and "anon public" key
///
/// In production, inject via --dart-define flags instead of hardcoding.
abstract class SupabaseConfig {
  SupabaseConfig._();

  // TODO: Replace with your Supabase Project URL
  static const String url = 'https://tuvgfpugfdeondeaxzmi.supabase.co';

  // TODO: Replace with the actual anon key from Supabase Dashboard -> Settings -> API
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1dmdmcHVnZmRlb25kZWF4em1pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgwMDAxNjYsImV4cCI6MjEwMzU3NjE2Nn0.ENe10_-nXbRTxyjUp385_VQZHoRVcT-rog05YvQHXhM';

  /// True when real credentials are configured.
  static bool get isConfigured =>
      url != 'https://placeholder.supabase.co' &&
      anonKey != 'placeholder-anon-key';
}
