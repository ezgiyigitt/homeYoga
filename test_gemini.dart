// ignore_for_file: avoid_print
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  try {
    const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: 'YOUR_GEMINI_API_KEY');
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
    final response = await model.generateContent([Content.text('Hello')]);
    print('SUCCESS: ${response.text}');
  } catch (e) {
    print('ERROR: $e');
  }
}
