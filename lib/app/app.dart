import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'navigation/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../l10n/generated/app_localizations.dart';
import '../presentation/shared/providers/locale_provider.dart';
import '../presentation/shared/providers/theme_provider.dart';

class HomeYogaApp extends ConsumerWidget {
  const HomeYogaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // `null` here means "follow the device language" — MaterialApp then
    // resolves against supportedLocales and falls back to English.
    final locale = ref.watch(localeProvider);

    // Resolve the appearance here rather than handing MaterialApp both a
    // light and a dark theme. Screens read their colours from AppColors,
    // which carries a single global appearance — so exactly one theme may be
    // built per frame, and it has to be the one actually shown.
    final platformBrightness =
        MediaQuery.maybeOf(context)?.platformBrightness ??
            PlatformDispatcher.instance.platformBrightness;

    final brightness = switch (themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => platformBrightness,
    };

    AppColors.setBrightness(brightness);
    final theme =
        brightness == Brightness.dark ? AppTheme.dark : AppTheme.light;

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: theme,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
      builder: (context, child) {
        // The appearance is resolved above, but MaterialApp builds its own
        // subtree afterwards — reassert it so everything painting this frame
        // reads the same value.
        AppColors.setBrightness(brightness);

        // Screens read AppColors directly rather than through an inherited
        // widget, and `const` route widgets are canonicalised, so a theme
        // change on its own would leave already-built screens painted in the
        // old appearance. Keying the subtree on the brightness rebuilds them.
        // GoRouter owns the route stack, so the same location comes straight
        // back — only ephemeral state such as scroll offset resets, which is
        // acceptable on a deliberate appearance change.
        //
        // The active locale is part of the key for the same reason: strings
        // held in widget state (rather than read fresh from `context.l10n`)
        // would otherwise survive a language change.
        return KeyedSubtree(
          key: ValueKey<String>(
            '${brightness.name}|'
            '${Localizations.maybeLocaleOf(context)?.toLanguageTag() ?? 'und'}',
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
