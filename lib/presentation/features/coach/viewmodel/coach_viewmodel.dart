import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_keys.dart';
import '../../../../core/constants/pain_rules.dart';
import '../../../../core/constants/practice_catalog.dart';
import '../../../../domain/entities/workout_entity.dart';
import '../../../../domain/entities/user_profile_entity.dart';
import '../../../../domain/entities/user_progress_entity.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/locale_provider.dart';

// Message model for the chat
class ChatMessage {
  final String text;
  final bool isUser;

  /// Mesaja iliştirilmiş, doğrudan başlatılabilir seans. Ağrı/şikâyet
  /// bildirildiğinde kural motorunun ürettiği plan buraya konur; sohbet
  /// balonunun altında "Başla" butonu olarak gösterilebilir.
  /// (`workout.id` zaten rota kimliği — WorkoutPlayer'a doğrudan verilir.)
  final WorkoutEntity? suggestedWorkout;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.suggestedWorkout,
  });
}

// State for the Coach feature
class CoachState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final int remainingQuestions;
  final bool isPro;
  final bool hasExhaustedCredits;

  CoachState({
    this.messages = const [],
    this.isLoading = false,
    this.remainingQuestions = 5,
    this.isPro = false,
    this.hasExhaustedCredits = false,
  });

  CoachState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    int? remainingQuestions,
    bool? isPro,
    bool? hasExhaustedCredits,
  }) {
    return CoachState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      remainingQuestions: remainingQuestions ?? this.remainingQuestions,
      isPro: isPro ?? this.isPro,
      hasExhaustedCredits: hasExhaustedCredits ?? this.hasExhaustedCredits,
    );
  }
}

// ViewModel
class CoachViewModel extends StateNotifier<CoachState> {
  final Ref _ref;
  String _systemInstruction = "You are a friendly, encouraging wellness and yoga coach.";
  final List<Map<String, String>> _conversationHistory = [];

  CoachViewModel(this._ref) : super(CoachState()) {
    _initChat();
  }

  Future<void> _initChat() async {
    // Sync credits and pro status
    final storage = _ref.read(localStorageProvider);
    final isPro = storage.isPro;
    final remaining = isPro ? 999 : storage.getCoachQuestionsRemaining();
    final userId = storage.userId ?? 'local';

    UserProfileEntity? userProfile;
    UserProgressEntity? userProgress;
    String? userName = storage.firstName.trim().isNotEmpty ? storage.firstName.trim() : null;

    try {
      final profileRepo = _ref.read(profileRepositoryProvider);
      final progressRepo = _ref.read(progressRepositoryProvider);

      final profileRes = await profileRepo.getProfile(userId);
      userProfile = profileRes.dataOrNull;

      final progressRes = await progressRepo.getProgress(userId);
      userProgress = progressRes.dataOrNull;

      if (userProfile != null && userProfile.firstName.trim().isNotEmpty) {
        userName = userProfile.firstName.trim();
      }
    } catch (e) {
      debugPrint('Failed to load user profile/progress for AI coach: $e');
    }

    _buildSystemInstruction(userProfile, userProgress);

    // Add welcome message in user's active language, personalized with name if known
    final lang = _ref.read(appLanguageProvider);
    final hasName = userName != null && userName.isNotEmpty;
    final welcomeText = switch (lang) {
      AppLanguage.turkish => hasName
          ? "Merhaba $userName! Ben senin yapay zekâ yoga ve sağlık koçunum. Bugün nasıl hissediyorsun?"
          : "Merhaba! Ben senin yapay zekâ yoga ve sağlık koçunum. Bugün nasıl hissediyorsun?",
      AppLanguage.french => hasName
          ? "Bonjour $userName ! Je suis votre coach yoga et bien-être IA. Comment vous sentez-vous aujourd'hui ?"
          : "Bonjour ! Je suis votre coach yoga et bien-être IA. Comment vous sentez-vous aujourd'hui ?",
      AppLanguage.spanish => hasName
          ? "¡Hola $userName! Soy tu coach de yoga y bienestar con IA. ¿Cómo te sientes hoy?"
          : "¡Hola! Soy tu coach de yoga y bienestar con IA. ¿Cómo te sientes hoy?",
      AppLanguage.chinese => hasName
          ? "你好 $userName！我是您的 AI 瑜伽与健康教练。今天感觉如何？"
          : "你好！我是您的 AI 瑜伽与健康教练。今天感觉如何？",
      _ => hasName
          ? "Hi $userName! I'm your AI yoga and wellness coach. How are you feeling today?"
          : "Hi! I'm your AI yoga and wellness coach. How are you feeling today?",
    };

    state = state.copyWith(
      messages: [
        ChatMessage(
          text: welcomeText,
          isUser: false,
        ),
      ],
      remainingQuestions: remaining,
      isPro: isPro,
      hasExhaustedCredits: false,
    );
  }

  void _buildSystemInstruction(UserProfileEntity? p, UserProgressEntity? prog) {
    final buffer = StringBuffer();
    buffer.writeln('You are an expert, empathetic, motivating and kind yoga & wellness coach for the Home Yoga app.');
    buffer.writeln('Your mission is to guide the user personally on their yoga, mobility, posture, and mindfulness journey.');
    buffer.writeln();
    buffer.writeln('--- USER PROFILE & CONTEXT ---');

    if (p != null) {
      if (p.firstName.trim().isNotEmpty) {
        buffer.writeln('- Name: ${p.firstName.trim()}');
      }
      buffer.writeln('- Fitness / Yoga Level: ${p.fitnessLevel.name} (tailor pose complexity, transitions and cues to this level)');
      if (p.goals.isNotEmpty) {
        buffer.writeln('- Personal Goals: ${p.goals.join(', ')} (actively align your encouragement and recommendations with these goals)');
      }
      if (p.physicalLimitations != null && p.physicalLimitations!.trim().isNotEmpty) {
        buffer.writeln('- HEALTH & PHYSICAL LIMITATIONS: "${p.physicalLimitations}" (CRITICAL SAFETY RULE: Always keep this limitation in mind! Give gentle modifications, avoid high strain on sensitive areas, and advise listening to the body)');
      }
      buffer.writeln('- Preferred session duration: ${p.preferredDurationMinutes} minutes');
      buffer.writeln('- Target weekly frequency: ${p.workoutFrequencyPerWeek} days/week');
      if (p.availableEquipment.isNotEmpty) {
        buffer.writeln('- Available equipment: ${p.availableEquipment.join(', ')}');
      }
    } else {
      buffer.writeln('- Fitness level: General / Beginner');
    }

    if (prog != null) {
      buffer.writeln('--- USER PROGRESS & STATS ---');
      buffer.writeln('- Current Streak: ${prog.currentStreak} consecutive day(s)');
      buffer.writeln('- Total Practices Completed: ${prog.totalPractices}');
      buffer.writeln('- Total Yoga Minutes: ${prog.totalMinutes} mins');
      buffer.writeln('- App Level: Level ${prog.level}');
    }

    buffer.writeln();
    buffer.writeln('--- COACHING BEHAVIOR RULES ---');
    buffer.writeln('1. Warm & Personal: Greet and address the user warmly by their name when appropriate. Acknowledge and praise their streak or dedication when relevant.');
    buffer.writeln('2. Concise & Structured: Keep answers short, practical, warm and well-structured. Avoid overwhelming walls of text.');
    buffer.writeln('3. Exact Language Match: Always reply in the EXACT SAME LANGUAGE the user writes to you in (Turkish if they speak Turkish, French if French, Spanish if Spanish, Chinese if Chinese, English if English).');
    buffer.writeln('4. App Exercise Library: You may ONLY recommend exercises that exist in this app library:');
    buffer.writeln('${Clip.all.join(', ')}.');
    buffer.writeln('Never invent a pose, a video, or a session name that is not in that list. Keep exercise names in English as listed.');
    buffer.writeln('5. Pain & Injury Safety: If the user mentions acute pain or a specific body complaint, note that the app triage engine will provide a custom plan. Remind the user to never push through sharp pain, stay gentle, and consult a doctor if severe.');

    _systemInstruction = buffer.toString();
  }

  void syncCredits() {
    final storage = _ref.read(localStorageProvider);
    final isPro = storage.isPro;
    final remaining = isPro ? 999 : storage.getCoachQuestionsRemaining();
    state = state.copyWith(
      remainingQuestions: remaining,
      isPro: isPro,
      hasExhaustedCredits: false,
    );
  }

  Future<void> watchRewardedAd() async {
    final storage = _ref.read(localStorageProvider);
    await storage.addCoachQuestions(2);
    final newCount = storage.getCoachQuestionsRemaining();
    state = state.copyWith(
      remainingQuestions: newCount,
      hasExhaustedCredits: false,
    );
  }

  void resetExhaustedFlag() {
    if (state.hasExhaustedCredits) {
      state = state.copyWith(hasExhaustedCredits: false);
    }
  }

  Future<void> resetQuestionsForTesting(int count) async {
    final storage = _ref.read(localStorageProvider);
    await storage.resetCoachQuestionsForTesting(count: count);
    state = state.copyWith(
      remainingQuestions: count,
      hasExhaustedCredits: count <= 0,
    );
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final storage = _ref.read(localStorageProvider);
    final isPro = storage.isPro;
    final remaining = storage.getCoachQuestionsRemaining();

    // Check if free user is out of question credits
    if (!isPro && remaining <= 0) {
      state = state.copyWith(
        hasExhaustedCredits: true,
        remainingQuestions: 0,
        isPro: false,
      );
      return;
    }

    if (!isPro) {
      await storage.decrementCoachQuestion();
      state = state.copyWith(
        remainingQuestions: storage.getCoachQuestionsRemaining(),
        hasExhaustedCredits: false,
      );
    }

    // Add user message to UI
    final newMessages = [...state.messages, ChatMessage(text: trimmed, isUser: true)];
    state = state.copyWith(messages: newMessages, isLoading: true);
    _conversationHistory.add({'role': 'user', 'content': trimmed});

    // ── Ağrı / şikâyet yolu ────────────────────────────────────────
    // Bu, yapay zekâya SORULMADAN önce çalışır. Bir kullanıcı "belim
    // ağrıyor" dediğinde ona ne önerileceği bir dil modeline
    // bırakılamayacak kadar önemli: plan kural motorundan gelir, üstelik
    // internet olmadan da gelir. Model sadece cevabı yumuşatmak için
    // (varsa) sonradan konuşur.
    final handled = await _tryPainFlow(trimmed);
    if (handled) return;

    if (ApiKeys.openRouterApiKey.isEmpty || ApiKeys.openRouterApiKey.startsWith('YOUR_')) {
      await Future.delayed(const Duration(seconds: 1));
      final mockResponse = ChatMessage(
        text: "Please set a valid API key in api_keys.dart.",
        isUser: false,
      );
      state = state.copyWith(
        messages: [...state.messages, mockResponse],
        isLoading: false,
      );
      return;
    }

    try {
      final reply = await _callAiService(trimmed);
      _conversationHistory.add({'role': 'assistant', 'content': reply});
      state = state.copyWith(
        messages: [...state.messages, ChatMessage(text: reply, isUser: false)],
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Coach API error: $e');
      String errorText = "Something went wrong while connecting. Could you try again?";
      if (e.toString().contains('429') || e.toString().contains('high demand')) {
        errorText = "The servers are busy right now. Take a deep breath and try again in a few seconds? 🧘‍♀️";
      }

      state = state.copyWith(
        messages: [...state.messages, ChatMessage(text: errorText, isUser: false)],
        isLoading: false,
      );
    }
  }

  /// Mesaj bir ağrı/şikâyet bildirimi mi? Öyleyse planı kural motoruyla
  /// üretip sohbete basar ve true döner (yapay zekâya hiç gidilmez).
  Future<bool> _tryPainFlow(String text) async {
    final region = PainTriage.detectRegion(text);
    final redFlag = PainTriage.hasRedFlag(text);

    // Sadece bir bölge adı geçmesi yetmez ("bacak günü yapayım mı?"),
    // bir şikâyet ifadesi de olmalı. Kırmızı bayrak her hâlükârda geçer.
    if (!redFlag && (region == null || !PainTriage.looksLikeComplaint(text))) {
      return false;
    }

    try {
      final userLang = _detectLanguage(text);
      final appLocale = _ref.read(appLanguageProvider).locale?.languageCode ?? 'en';
      final userId = _ref.read(localStorageProvider).userId ?? 'local';
      final res = await _ref
          .read(painReliefUseCaseProvider)
          .execute(
            userId,
            text,
            turkish: userLang == 'tr',
            userLang: userLang,
            appLang: appLocale,
          );

      if (res.isFailure || res.dataOrNull == null) return false;
      final plan = res.dataOrNull!;

      final buffer = StringBuffer()
        ..writeln(plan.title)
        ..writeln()
        ..writeln(plan.advice);

      if (plan.hasWorkout) {
        final planHeader = switch (userLang) {
          'tr' => 'Bugünün planı (${plan.workout!.estimatedMinutes} dk):',
          'fr' => 'Plan du jour (${plan.workout!.estimatedMinutes} min) :',
          'es' => 'Plan de hoy (${plan.workout!.estimatedMinutes} min):',
          'zh' => '今日计划 (${plan.workout!.estimatedMinutes} 分钟):',
          _ => 'Today\'s plan (${plan.workout!.estimatedMinutes} min):',
        };
        buffer
          ..writeln()
          ..writeln(planHeader);
        for (var i = 0; i < plan.workout!.exercises.length; i++) {
          final ex = plan.workout!.exercises[i].exercise;
          if (ex != null) buffer.writeln('${i + 1}. ${ex.name}');
        }
        if (plan.avoidedToday.isNotEmpty) {
          final avoidedHeader = switch (userLang) {
            'tr' => 'Bugün bilerek çıkardıklarım: ${plan.avoidedToday.join(', ')}.',
            'fr' => 'Volontairement retirés aujourd\'hui : ${plan.avoidedToday.join(', ')}.',
            'es' => 'Voluntariamente omitidos hoy: ${plan.avoidedToday.join(', ')}.',
            'zh' => '今日特意排除的动作: ${plan.avoidedToday.join(', ')}。',
            _ => 'Left out on purpose today: ${plan.avoidedToday.join(', ')}.',
          };
          buffer
            ..writeln()
            ..writeln(avoidedHeader);
        }
      }

      final reply = buffer.toString().trim();
      _conversationHistory.add({'role': 'assistant', 'content': reply});
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            text: reply,
            isUser: false,
            suggestedWorkout: plan.workout,
          ),
        ],
        isLoading: false,
      );
      return true;
    } catch (e) {
      debugPrint('Pain flow failed, falling back to AI: $e');
      return false;
    }
  }

  /// Kullanıcının yazdığı mesajın dilini tespit eder: Türkçe, Fransızca, İspanyolca, Çince veya İngilizce.
  String _detectLanguage(String text) {
    // Çince karakter kontrolü (CJK Unified Ideographs)
    if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(text)) {
      return 'zh';
    }

    final t = text.toLowerCase();
    if (RegExp('[ığşçöü]').hasMatch(t) ||
        ['agri', 'agriyor', 'benim', 'bugun', 'yorgun', 'nasil', 've', 'bir', 'boynum', 'belim', 'dizim', 'omzum']
            .any((w) => t.contains(w))) {
      return 'tr';
    }
    if (RegExp('[éèêëàâùûôîï]').hasMatch(t) ||
        ['mal', 'douleur', 'cou', 'dos', 'genou', 'fatigue', 'je', 'suis', 'mon', 'ma', 'mes', 'pour', 'que', 'avec', 'faire']
            .any((w) => t.split(RegExp(r'\s+')).contains(w))) {
      return 'fr';
    }
    if (RegExp('[ñáíóú]').hasMatch(t) ||
        ['dolor', 'duele', 'cuello', 'espalda', 'rodilla', 'cintura', 'cansado', 'tengo', 'para', 'hacer', 'con', 'estoy']
            .any((w) => t.split(RegExp(r'\s+')).contains(w))) {
      return 'es';
    }
    return 'en';
  }

  Future<String> _callAiService(String userMessage) async {
    // 1. Try OpenRouter with candidate models (Primary: Gemma 4 26B, followed by fallbacks)
    final modelsToTry = [
      ApiKeys.openRouterModel,
      ...ApiKeys.fallbackModels.where((m) => m != ApiKeys.openRouterModel),
    ];

    final openRouterUrl = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    final messagesPayload = [
      {'role': 'system', 'content': _systemInstruction},
      ..._conversationHistory,
    ];

    String? lastError;

    for (final model in modelsToTry) {
      try {
        debugPrint('Coach AI: Trying model $model...');
        final response = await http.post(
          openRouterUrl,
          headers: {
            'Authorization': 'Bearer ${ApiKeys.openRouterApiKey}',
            'Content-Type': 'application/json; charset=utf-8',
            'HTTP-Referer': 'https://github.com/ezgiyigitt/homeYoga',
            'X-Title': 'Home Yoga App',
          },
          body: jsonEncode({
            'model': model,
            'messages': messagesPayload,
          }),
        ).timeout(const Duration(seconds: 35));

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
          final choices = data['choices'] as List?;
          if (choices != null && choices.isNotEmpty) {
            final content = choices[0]['message']?['content'] as String?;
            if (content != null && content.trim().isNotEmpty) {
              debugPrint('Coach AI: Response received from $model');
              return content.trim();
            }
          }
        } else {
          debugPrint('Coach AI: $model returned status ${response.statusCode}');
          lastError = 'HTTP ${response.statusCode}: ${response.body}';
        }
      } catch (e) {
        debugPrint('Coach AI: $model failed with error: $e');
        lastError = e.toString();
      }
    }

    // 2. Secondary fallback: direct Google Gemini API if configured
    if (ApiKeys.geminiApiKey.isNotEmpty && !ApiKeys.geminiApiKey.startsWith('YOUR_')) {
      try {
        final gemini = GenerativeModel(
          model: 'gemini-flash-latest',
          apiKey: ApiKeys.geminiApiKey,
          systemInstruction: Content.system(_systemInstruction),
        );
        final res = await gemini.generateContent([Content.text(userMessage)]);
        if (res.text != null && res.text!.trim().isNotEmpty) {
          return res.text!.trim();
        }
      } catch (_) {}
    }

    throw Exception(lastError ?? 'Could not get response from AI');
  }
}

final coachViewModelProvider = StateNotifierProvider<CoachViewModel, CoachState>((ref) {
  return CoachViewModel(ref);
});

