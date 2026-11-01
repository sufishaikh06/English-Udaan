import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/speech_service.dart';
import 'core/services/auth_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_providers.dart';
import 'features/auth/presentation/auth_screens.dart';
import 'features/dictionary/presentation/dictionary_screen.dart';
import 'features/learning/presentation/grammar_learning_screen.dart';
import 'features/learning/presentation/learning_hub_screen.dart';
import 'features/learning/presentation/learning_screens.dart';
import 'features/learning/presentation/picture_learning_screens.dart';
import 'features/learning/presentation/sentence_learning_screen.dart';
import 'features/profile/presentation/profile_screens.dart';
import 'features/practice/domain/practice_models.dart';
import 'features/practice/presentation/practice_screens.dart';
import 'features/progress/presentation/progress_screen.dart';
import 'shared/widgets/app_components.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  try {
    // Android reads the checked-in google-services.json. Web requires a
    // separately generated FirebaseOptions configuration, which this project
    // does not currently include.
    if (!kIsWeb) {
      await Firebase.initializeApp();
    }
  } catch (_) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firebase.init.failed', true);
  }
  runApp(const ProviderScope(child: EnglishUdaanApp()));
}

enum AppLanguage {
  urdu(Locale('ur')),
  english(Locale('en'));

  const AppLanguage(this.locale);

  final Locale locale;

  static AppLanguage fromCode(String? code) {
    return code == 'en' ? AppLanguage.english : AppLanguage.urdu;
  }
}

const appVersionLabel = '0.1.0+1';

class AppPreferences {
  const AppPreferences({
    required this.language,
    required this.themeMode,
    this.speechEnabled = true,
    this.speechRate = SpeechPreferences.defaultRate,
  });

  final AppLanguage language;
  final ThemeMode themeMode;
  final bool speechEnabled;
  final double speechRate;

  AppPreferences copyWith({
    AppLanguage? language,
    ThemeMode? themeMode,
    bool? speechEnabled,
    double? speechRate,
  }) {
    return AppPreferences(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      speechEnabled: speechEnabled ?? this.speechEnabled,
      speechRate: speechRate ?? this.speechRate,
    );
  }
}

class PreferencesController extends Notifier<AppPreferences> {
  static const _languageKey = 'language';
  static const _themeKey = 'theme_mode';

  @override
  AppPreferences build() {
    _load();
    return const AppPreferences(
      language: AppLanguage.urdu,
      themeMode: ThemeMode.system,
    );
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    final storedRate = preferences.get(SpeechPreferences.rateKey);
    state = AppPreferences(
      language: AppLanguage.fromCode(preferences.getString(_languageKey)),
      themeMode: _themeModeFromName(preferences.getString(_themeKey)),
      speechEnabled: preferences.getBool(SpeechPreferences.enabledKey) ?? true,
      speechRate: SpeechPreferences.clampRate(
        storedRate is num
            ? storedRate.toDouble()
            : SpeechPreferences.defaultRate,
      ),
    );
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = state.copyWith(language: language);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languageKey, language.locale.languageCode);
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeKey, themeMode.name);
  }

  Future<void> setSpeechEnabled(bool enabled) async {
    state = state.copyWith(speechEnabled: enabled);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(SpeechPreferences.enabledKey, enabled);
  }

  Future<void> setSpeechRate(double rate) async {
    final clamped = SpeechPreferences.clampRate(rate);
    state = state.copyWith(speechRate: clamped);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(SpeechPreferences.rateKey, clamped);
  }

  ThemeMode _themeModeFromName(String? name) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => ThemeMode.system,
    );
  }
}

final preferencesProvider =
    NotifierProvider<PreferencesController, AppPreferences>(
      PreferencesController.new,
    );

class EnglishUdaanApp extends ConsumerWidget {
  const EnglishUdaanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // Firebase restores an existing login automatically after app relaunch.
    // Rehydrate the in-memory progress session for that first auth emission;
    // otherwise Firebase appears signed in but ProgressRepository remains in
    // guest mode and correctly refuses all progress writes.
    ref.listen<AsyncValue<AuthUser?>>(authStateProvider, (previous, next) {
      final isInitialAuthEmission = previous == null || previous.isLoading;
      if (!isInitialAuthEmission) return;
      next.whenData((user) {
        final cloudProgress = ref.read(cloudProgressServiceProvider);
        if (user == null) {
          unawaited(cloudProgress.clearActiveAccount());
        } else {
          unawaited(() async {
            await cloudProgress.prepareForAccount();
            await cloudProgress.syncFromCloud();
          }());
        }
      });
    });

    final preferences = ref.watch(preferencesProvider);
    return MaterialApp.router(
      title: 'English Udaan',
      debugShowCheckedModeBanner: false,
      locale: preferences.language.locale,
      supportedLocales: AppLanguage.values.map((language) => language.locale).toList(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: preferences.themeMode,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      routerConfig: _routerForAuthState(authState),
    );
  }

  GoRouter _routerForAuthState(AsyncValue<AuthUser?> authState) {
    // Learning remains available while Firebase restores (or lacks) a session.
    return _buildAppRouter(authState.value != null);
  }

  GoRouter _buildAppRouter(bool isAuthenticated) {
    return GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
          builder: (context, state, child) =>
              AppShell(location: state.uri.path, child: child),
          routes: [
            GoRoute(
                path: '/home',
                builder: (context, state) =>
                    const PlaceholderScreen(destination: AppDestination.home),
              ),
            GoRoute(
                path: '/learn',
                builder: (context, state) => const LearningHubScreen(),
                routes: [
                  GoRoute(
                    path: 'alphabet',
                    builder: (context, state) => const AlphabetScreen(),
                  ),
                  GoRoute(
                    path: 'alphabet/:id',
                    builder: (context, state) =>
                        LetterDetailScreen(id: state.pathParameters['id']!),
                  ),
                  GoRoute(
                    path: 'vocabulary',
                    builder: (context, state) => const VocabularyScreen(),
                  ),
                  GoRoute(
                    path: 'pictures',
                    builder: (context, state) => const PictureCategoriesScreen(),
                  ),
                  GoRoute(
                    path: 'pictures/:categoryId',
                    builder: (context, state) => PictureItemsScreen(
                      categoryId: state.pathParameters['categoryId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'sentences',
                    builder: (context, state) => const SentenceLearningScreen(),
                  ),
                  GoRoute(
                    path: 'grammar',
                    builder: (context, state) => const GrammarLessonsScreen(),
                  ),
                  GoRoute(
                    path: 'grammar/:id',
                    builder: (context, state) =>
                        GrammarLessonDetailScreen(id: state.pathParameters['id']!),
                  ),
                  GoRoute(
                    path: 'dictionary',
                    builder: (context, state) => const DictionaryScreen(),
                  ),
                ],
              ),
            GoRoute(
                path: '/practice',
                builder: (context, state) => const PracticeHomeScreen(),
                routes: [
                  GoRoute(
                    path: 'quiz/:category',
                    builder: (context, state) {
                      final categoryName = state.pathParameters['category']!;
                      final category = PracticeCategory.values.firstWhere(
                        (c) => c.name == categoryName,
                        orElse: () => PracticeCategory.mixed,
                      );
                      return PracticeQuizScreen(category: category);
                    },
                  ),
                ],
              ),
            GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
              ),
            GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'help',
                    builder: (context, state) => const HelpScreen(),
                  ),
                  GoRoute(
                    path: 'about',
                    builder: (context, state) => const AboutScreen(),
                  ),
                ],
              ),
          ],
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
          routes: [
            GoRoute(
              path: 'audio',
              builder: (context, state) => const AudioSettingsScreen(),
            ),
          ],
        ),
        if (!isAuthenticated)
          GoRoute(
            path: '/auth/login',
            builder: (context, state) => const LoginScreen(),
          ),
        if (!isAuthenticated)
          GoRoute(
            path: '/auth/register',
            builder: (context, state) => const RegisterScreen(),
          ),
      ],
    );
  }
}

enum AppDestination { home, learn, practice, progress, profile }

extension AppDestinationText on AppDestination {
  IconData get icon => switch (this) {
    AppDestination.home => Icons.home_outlined,
    AppDestination.learn => Icons.menu_book_outlined,
    AppDestination.practice => Icons.quiz_outlined,
    AppDestination.progress => Icons.insights_outlined,
    AppDestination.profile => Icons.person_outline,
  };

  String label(AppLanguage language) {
    const urdu = ['ہوم', 'سیکھیں', 'پریکٹس', 'پیش رفت', 'پروفائل'];
    const english = ['Home', 'Learn', 'Practice', 'Progress', 'Profile'];
    return (language == AppLanguage.urdu ? urdu : english)[index];
  }

  String title(AppLanguage language) {
    const urdu = ['انگلش اُڑان', 'سیکھیں', 'پریکٹس', 'پیش رفت', 'پروفائل'];
    const english = [
      'English Udaan',
      'Learn',
      'Practice',
      'Progress',
      'Profile',
    ];
    return (language == AppLanguage.urdu ? urdu : english)[index];
  }
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(preferencesProvider).language;
    final destinations = AppDestination.values;
    final currentIndex = destinations.indexWhere(
      (destination) => location == '/${destination.name}',
    );
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex < 0 ? 0 : currentIndex,
        onDestinationSelected: (index) =>
            context.go('/${destinations[index].name}'),
        destinations: [
          for (final destination in destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              label: destination.label(language),
            ),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends ConsumerWidget {
  const PlaceholderScreen({super.key, required this.destination});

  final AppDestination destination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(preferencesProvider).language;
    final isUrdu = language == AppLanguage.urdu;
    return Scaffold(
      appBar: AppBar(
        title: destination == AppDestination.home
            ? const AppLogo()
            : Text(destination.title(language)),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            tooltip: isUrdu ? 'ترتیبات' : 'Settings',
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: destination == AppDestination.home
              ? _HomeFoundation(language: language)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      destination.icon,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      destination.title(language),
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isUrdu
                          ? 'یہ سیکشن اگلے مرحلوں میں دستیاب ہوگا۔'
                          : 'This section will be available in a later phase.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _HomeFoundation extends StatelessWidget {
  const _HomeFoundation({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final isUrdu = language == AppLanguage.urdu;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.medium),
      children: [
        Text(
          isUrdu
              ? 'انگریزی سیکھنے کا سفر شروع کریں'
              : 'Start your English learning journey',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          isUrdu
              ? 'روزانہ تھوڑا سیکھیں، اعتماد کے ساتھ بولیں۔'
              : 'Learn a little every day and speak with confidence.',
        ),
        const SizedBox(height: AppSpacing.large),
        AppSectionHeader(
          title: isUrdu ? 'سیکھنا شروع کریں' : 'Continue learning',
        ),
        const SizedBox(height: AppSpacing.small),
        LearningCard(
          title: isUrdu ? 'حروف تہجی' : 'English alphabet',
          subtitle: isUrdu
              ? 'A سے Z تک حروف اور تلفظ'
              : 'Letters A to Z and pronunciation',
          icon: Icons.text_fields_outlined,
          color: AppColors.primary,
          onTap: () => context.push('/learn/alphabet'),
        ),
        const SizedBox(height: AppSpacing.small),
        LearningCard(
          title: isUrdu ? 'الفاظ سیکھیں' : 'Learn words',
          subtitle: isUrdu
              ? 'آسان الفاظ، معنی اور مثالیں'
              : 'Useful words, meanings, and examples',
          icon: Icons.translate_outlined,
          color: const Color(0xFF8A5CF6),
          onTap: () => context.push('/learn/vocabulary'),
        ),
        const SizedBox(height: AppSpacing.small),
        LearningCard(
          title: isUrdu ? 'تصاویر سے سیکھیں' : 'Learn with pictures',
          subtitle: isUrdu
              ? 'پھل، سبزیاں اور جانور'
              : 'Fruits, vegetables, and animals',
          icon: Icons.image_outlined,
          color: const Color(0xFFF59E0B),
          onTap: () => context.push('/learn/pictures'),
        ),
        const SizedBox(height: AppSpacing.small),
        LearningCard(
          title: isUrdu ? 'جملے اور پیراگراف' : 'Sentences & paragraphs',
          subtitle: isUrdu
              ? 'انگریزی جملے پڑھیں اور سنیں'
              : 'Read and listen to English lessons',
          icon: Icons.subject_outlined,
          color: const Color(0xFF159A9C),
          onTap: () => context.push('/learn/sentences'),
        ),
        const SizedBox(height: AppSpacing.small),
        LearningCard(
          title: isUrdu ? 'انگریزی گرامر' : 'English grammar',
          subtitle: isUrdu
              ? 'قواعد، مثالیں اور عام غلطیاں'
              : 'Rules, examples, and common errors',
          icon: Icons.rule_outlined,
          color: const Color(0xFF087B7D),
          onTap: () => context.push('/learn/grammar'),
        ),
        const SizedBox(height: AppSpacing.small),
        LearningCard(
          title: isUrdu ? 'پریکٹس اور کوئز' : 'Practice & quiz',
          subtitle: isUrdu
              ? 'انٹرایکٹو سوالات سے اپنی صلاحیت آزمائیں'
              : 'Test your skills with interactive quizzes',
          icon: Icons.quiz_outlined,
          color: const Color(0xFF2563EB),
          onTap: () => context.push('/practice'),
        ),
        const SizedBox(height: AppSpacing.large),
        AppSectionHeader(title: isUrdu ? 'آپ کی پیش رفت' : 'Your progress'),
        const SizedBox(height: AppSpacing.small),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    value: 0,
                    strokeWidth: 7,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Text(
                    isUrdu
                        ? 'پہلا سبق مکمل کر کے اپنی پیش رفت دیکھیں۔'
                        : 'Complete your first lesson to see your progress.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider);
    final controller = ref.read(preferencesProvider.notifier);
    final isUrdu = preferences.language == AppLanguage.urdu;

    return Scaffold(
      appBar: AppBar(title: Text(isUrdu ? 'ترتیبات' : 'Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            isUrdu ? 'زبان' : 'Language',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<AppLanguage>(
            segments: const [
              ButtonSegment(value: AppLanguage.urdu, label: Text('اردو')),
              ButtonSegment(value: AppLanguage.english, label: Text('English')),
            ],
            selected: {preferences.language},
            onSelectionChanged: (selection) =>
                controller.setLanguage(selection.first),
          ),
          const SizedBox(height: 28),
          Text(
            isUrdu ? 'ظاہری انداز' : 'Appearance',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: [
              for (final themeMode in ThemeMode.values)
                ButtonSegment(
                  value: themeMode,
                  label: Text(_themeLabel(themeMode, isUrdu)),
                ),
            ],
            selected: {preferences.themeMode},
            onSelectionChanged: (selection) =>
                controller.setThemeMode(selection.first),
          ),
          const SizedBox(height: 28),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.volume_up_outlined),
            title: Text(isUrdu ? 'آواز' : 'Audio'),
            subtitle: Text(
              preferences.speechEnabled
                  ? (isUrdu ? 'تلفظ چالو ہے' : 'Pronunciation is on')
                  : (isUrdu ? 'تلفظ بند ہے' : 'Pronunciation is off'),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/audio'),
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode, bool isUrdu) {
    if (isUrdu) {
      return switch (mode) {
        ThemeMode.system => 'سسٹم کے مطابق',
        ThemeMode.light => 'روشن',
        ThemeMode.dark => 'تاریک',
      };
    }
    return switch (mode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };
  }
}
