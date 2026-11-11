enum BackendMode { auto, mock, supabase }

class AppEnvironment {
  const AppEnvironment({
    this.supabaseUrl,
    this.supabaseAnonKey,
    this.backendMode = BackendMode.auto,
  });

  factory AppEnvironment.fromDefines() {
    const url = String.fromEnvironment('SUPABASE_URL');
    const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    const modeRaw =
        String.fromEnvironment('BACKEND_MODE', defaultValue: 'auto');

    final mode = switch (modeRaw.toLowerCase()) {
      'mock' => BackendMode.mock,
      'supabase' => BackendMode.supabase,
      _ => BackendMode.auto,
    };

    return AppEnvironment(
      supabaseUrl: url.isEmpty ? null : url,
      supabaseAnonKey: anonKey.isEmpty ? null : anonKey,
      backendMode: mode,
    );
  }

  static const AppEnvironment mock =
      AppEnvironment(backendMode: BackendMode.mock);

  final String? supabaseUrl;
  final String? supabaseAnonKey;
  final BackendMode backendMode;

  bool get hasSupabaseCredentials =>
      supabaseUrl != null &&
      supabaseUrl!.isNotEmpty &&
      supabaseAnonKey != null &&
      supabaseAnonKey!.isNotEmpty;

  bool get useSupabase => switch (backendMode) {
        BackendMode.mock => false,
        BackendMode.supabase => true,
        BackendMode.auto => hasSupabaseCredentials,
      };
}
