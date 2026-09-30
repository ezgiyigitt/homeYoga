class ApiKeys {
  ApiKeys._();

  // OpenRouter API Key & Models. Provide a real key via --dart-define or build config.
  static const String openRouterApiKey =
      String.fromEnvironment('OPENROUTER_API_KEY', defaultValue: 'YOUR_OPENROUTER_API_KEY');
  static const String openRouterModel = 'google/gemma-4-26b-a4b-it:free';

  // Fallback models when primary model hits upstream rate limits
  static const List<String> fallbackModels = [
    'google/gemma-4-26b-a4b-it:free',
    'minimax/minimax-m3:free',
    'nvidia/nemotron-3.5-lightning:free',
  ];

  // Google Gemini API Key from Google AI Studio (fallback). Provide a real key via --dart-define.
  static const String geminiApiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: 'YOUR_GEMINI_API_KEY');
}

