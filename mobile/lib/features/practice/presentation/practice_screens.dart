import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/speech_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../main.dart';
import '../../../shared/widgets/app_components.dart';
import '../../learning/data/learning_repository.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/practice_repository.dart';
import '../domain/practice_models.dart';

class PracticeHomeScreen extends ConsumerStatefulWidget {
  const PracticeHomeScreen({super.key, this.repository});

  final PracticeRepository? repository;

  @override
  ConsumerState<PracticeHomeScreen> createState() => _PracticeHomeScreenState();
}

class _PracticeHomeScreenState extends ConsumerState<PracticeHomeScreen> {
  late final PracticeRepository _repository =
      widget.repository ??
      PracticeRepository(learningRepository: LearningRepository.bundled());

  Map<PracticeCategory, ({int score, int total})?> _lastScores = {};

  @override
  void initState() {
    super.initState();
    _loadLastScores();
  }

  Future<void> _loadLastScores() async {
    final scores = <PracticeCategory, ({int score, int total})?>{};
    for (final category in PracticeCategory.values) {
      scores[category] = await _repository.getLastQuizResult(category);
    }
    if (mounted) {
      setState(() => _lastScores = scores);
    }
  }

  void _startQuiz(PracticeCategory category) {
    context
        .push('/practice/quiz/${category.name}')
        .then((_) => _loadLastScores());
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(preferencesProvider).language;
    final isUrdu = language == AppLanguage.urdu;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUrdu ? 'پریکٹس اور کوئز' : 'Practice & Quizzes'),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            tooltip: isUrdu ? 'ترتیبات' : 'Settings',
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          Text(
            isUrdu ? 'اپنی مہارت آزمائیں' : 'Test Your Skills',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xSmall),
          Text(
            isUrdu
                ? 'الفاظ، تصاویر، جملوں اور گرامر کے انٹرایکٹو سوالات سے مشق کریں۔'
                : 'Interactive quizzes for vocabulary, pictures, sentences, and grammar.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedLight),
          ),
          const SizedBox(height: AppSpacing.large),
          AppSectionHeader(
            title: isUrdu ? 'کوئز کی کیٹیگریز' : 'Quiz Categories',
          ),
          const SizedBox(height: AppSpacing.small),
          for (final category in PracticeCategory.values) ...[
            _PracticeCategoryCard(
              category: category,
              isUrdu: isUrdu,
              lastScore: _lastScores[category],
              onTap: () => _startQuiz(category),
            ),
            const SizedBox(height: AppSpacing.small),
          ],
        ],
      ),
    );
  }
}

class _PracticeCategoryCard extends StatelessWidget {
  const _PracticeCategoryCard({
    required this.category,
    required this.isUrdu,
    this.lastScore,
    required this.onTap,
  });

  final PracticeCategory category;
  final bool isUrdu;
  final ({int score, int total})? lastScore;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = isUrdu ? category.titleUrdu() : category.titleEnglish();
    final subtitle = isUrdu
        ? category.subtitleUrdu()
        : category.subtitleEnglish();
    final color = category.color();

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.medium,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: AppRadii.small,
                ),
                child: SizedBox(
                  height: 52,
                  width: 52,
                  child: Icon(category.icon(), color: color),
                ),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xSmall),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedLight,
                      ),
                    ),
                    if (lastScore != null) ...[
                      const SizedBox(height: AppSpacing.xSmall),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isUrdu
                                ? 'آخری اسکور: ${lastScore!.score}/${lastScore!.total}'
                                : 'Last score: ${lastScore!.score}/${lastScore!.total}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              FilledButton.tonal(
                onPressed: onTap,
                child: Text(isUrdu ? 'شروع کریں' : 'Start'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PracticeQuizScreen extends ConsumerStatefulWidget {
  const PracticeQuizScreen({
    super.key,
    required this.category,
    this.repository,
    this.speechService,
    this.initialQuestions,
  });

  final PracticeCategory category;
  final PracticeRepository? repository;
  final SpeechService? speechService;
  final List<PracticeQuestion>? initialQuestions;

  @override
  ConsumerState<PracticeQuizScreen> createState() => _PracticeQuizScreenState();
}

class _PracticeQuizScreenState extends ConsumerState<PracticeQuizScreen> {
  late final PracticeRepository _repository =
      widget.repository ??
      PracticeRepository(learningRepository: LearningRepository.bundled());
  late final SpeechService _speech =
      widget.speechService ?? DeviceSpeechService();

  late Future<List<PracticeQuestion>> _questionsFuture;
  QuizSession? _session;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuestions != null) {
      _session = QuizSession(
        category: widget.category,
        questions: widget.initialQuestions!,
      );
      _isLoading = false;
    } else {
      _loadQuestions();
    }
  }

  void _loadQuestions() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _questionsFuture = _repository.getQuizQuestions(
      category: widget.category,
      count: 10,
    );
    _questionsFuture
        .then((questions) {
          if (mounted) {
            if (questions.isEmpty) {
              setState(() {
                _isLoading = false;
                _errorMessage =
                    'No practice questions available for this category.';
              });
            } else {
              setState(() {
                _session = QuizSession(
                  category: widget.category,
                  questions: questions,
                );
                _isLoading = false;
              });
            }
          }
        })
        .catchError((error) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = error.toString();
            });
          }
        });
  }

  Future<void> _speak(String? text) async {
    if (text == null || text.trim().isEmpty) return;
    try {
      if (widget.speechService != null) {
        await _speech.speak(text);
      } else {
        final preferences = ref.read(preferencesProvider);
        await DeviceSpeechService(
          preferences: SpeechPreferences(
            enabled: preferences.speechEnabled,
            rate: preferences.speechRate,
          ),
        ).speak(text);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _handleOptionSelect(int index) {
    if (_session == null || _session!.isAnswerSubmitted) return;
    setState(() {
      _session!.selectOption(index);
    });
  }

  void _handleSubmitAnswer() {
    if (_session == null || _session!.selectedOptionIndex == null) return;
    setState(() {
      _session!.submitAnswer();
    });
  }

  Future<void> _handleNextQuestion() async {
    if (_session == null) return;
    setState(() {
      _session!.nextQuestion();
    });

    if (_session!.isCompleted) {
      // Persist result
      await _repository.saveQuizResult(
        category: widget.category,
        score: _session!.score,
        total: _session!.totalQuestions,
      );
      await ref.read(cloudProgressServiceProvider).syncToCloud().catchError((_) {});
    }
  }

  void _handleRestart() {
    if (widget.initialQuestions != null) {
      setState(() {
        _session = QuizSession(
          category: widget.category,
          questions: widget.initialQuestions!,
        );
      });
    } else {
      _loadQuestions();
    }
  }

  Future<bool> _onWillPop() async {
    if (_session == null || _session!.isCompleted || _session!.isEmpty) {
      return true;
    }
    final isUrdu = Directionality.of(context) == TextDirection.rtl;
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isUrdu ? 'کوئز چھوڑیں؟' : 'Leave Quiz?'),
        content: Text(
          isUrdu
              ? 'کیا آپ واقعی یہ کوئز چھوڑنا چاہتے ہیں؟ موجودہ پیش رفت محفوظ نہیں ہوگی۔'
              : 'Are you sure you want to leave this quiz? Your current progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(isUrdu ? 'جاری رکھیں' : 'Continue'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(isUrdu ? 'چھوڑ دیں' : 'Leave'),
          ),
        ],
      ),
    );
    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isUrdu = Directionality.of(context) == TextDirection.rtl;
    final title = isUrdu
        ? widget.category.titleUrdu()
        : widget.category.titleEnglish();

    return PopScope(
      canPop: _session == null || _session!.isCompleted || _session!.isEmpty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await _onWillPop();
        if (shouldLeave && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: isUrdu ? 'بند کریں' : 'Close',
            onPressed: () async {
              final shouldLeave = await _onWillPop();
              if (shouldLeave && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: _buildBody(context, isUrdu),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isUrdu) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null || _session == null || _session!.isEmpty) {
      return AppStateView(
        icon: Icons.quiz_outlined,
        title: isUrdu ? 'سوالات دستیاب نہیں' : 'Questions Unavailable',
        message:
            _errorMessage ??
            (isUrdu
                ? 'اس کیٹیگری کے لیے ابھی سوالات تیار نہیں کیے جا سکے۔'
                : 'Questions could not be prepared for this category.'),
        actionLabel: isUrdu ? 'واپس جائیں' : 'Go Back',
        onAction: () => Navigator.of(context).pop(),
      );
    }

    if (_session!.isCompleted) {
      return _PracticeResultsView(
        session: _session!,
        isUrdu: isUrdu,
        onRetry: _handleRestart,
        onBack: () => Navigator.of(context).pop(),
      );
    }

    final question = _session!.currentQuestion!;
    final currentNumber = _session!.currentIndex + 1;
    final total = _session!.totalQuestions;
    final progress = currentNumber / total;

    return Column(
      children: [
        // Progress header
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.medium,
            vertical: AppSpacing.small,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isUrdu
                        ? 'سوال $currentNumber از $total'
                        : 'Question $currentNumber of $total',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    isUrdu
                        ? 'اسکور: ${_session!.score}'
                        : 'Score: ${_session!.score}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.small),
              LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
        ),

        // Scrollable question area
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.medium),
            children: [
              // Question Card
              Card(
                elevation: 0,
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.medium,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Instruction
                      Text(
                        isUrdu
                            ? question.instructionUrdu
                            : question.instructionEnglish,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.medium),

                      // Optional image
                      if (question.imageAssetPath != null) ...[
                        ClipRRect(
                          borderRadius: AppRadii.small,
                          child: Container(
                            height: 140,
                            color: Theme.of(context).colorScheme.surface,
                            child: Image.asset(
                              question.imageAssetPath!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 48,
                                      color: AppColors.mutedLight,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.medium),
                      ],

                      // Question Prompt
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Directionality(
                              textDirection: question.isPromptUrdu
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              child: Text(
                                question.prompt,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                          if (question.ttsText != null)
                            AudioButton(
                              label: 'Listen to question',
                              onPressed: () => _speak(question.ttsText),
                            ),
                        ],
                      ),

                      if (question.promptSecondary != null) ...[
                        const SizedBox(height: AppSpacing.xSmall),
                        Text(
                          question.promptSecondary!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.mutedLight),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.medium),

              // Options
              for (var i = 0; i < question.options.length; i++) ...[
                _buildOptionTile(
                  context: context,
                  question: question,
                  optionIndex: i,
                  optionText: question.options[i],
                  isUrdu: isUrdu,
                ),
                const SizedBox(height: AppSpacing.small),
              ],

              // Feedback Banner after submission
              if (_session!.isAnswerSubmitted) ...[
                const SizedBox(height: AppSpacing.small),
                _buildFeedbackBanner(context, question, isUrdu),
              ],
            ],
          ),
        ),

        // Bottom Action Bar
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: _session!.isAnswerSubmitted
                  ? ElevatedButton(
                      onPressed: _handleNextQuestion,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.medium,
                        ),
                      ),
                      child: Text(
                        _session!.currentIndex == total - 1
                            ? (isUrdu ? 'نتائج دیکھیں' : 'See Results')
                            : (isUrdu ? 'اگلا سوال' : 'Next Question'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _session!.selectedOptionIndex != null
                          ? _handleSubmitAnswer
                          : null,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.medium,
                        ),
                      ),
                      child: Text(
                        isUrdu ? 'جواب جمع کریں' : 'Submit Answer',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required PracticeQuestion question,
    required int optionIndex,
    required String optionText,
    required bool isUrdu,
  }) {
    final isSelected = _session!.selectedOptionIndex == optionIndex;
    final isSubmitted = _session!.isAnswerSubmitted;
    final isCorrect = optionIndex == question.correctIndex;

    Color? backgroundColor;
    BorderSide borderSide = BorderSide(
      color: Theme.of(context).colorScheme.outlineVariant,
      width: 1.5,
    );
    Widget trailingIcon = const SizedBox(width: 24);

    if (isSubmitted) {
      if (isCorrect) {
        backgroundColor = Colors.green.withValues(alpha: 0.12);
        borderSide = const BorderSide(color: Colors.green, width: 2);
        trailingIcon = const Icon(Icons.check_circle, color: Colors.green);
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.withValues(alpha: 0.12);
        borderSide = const BorderSide(color: Colors.red, width: 2);
        trailingIcon = const Icon(Icons.cancel, color: Colors.red);
      }
    } else if (isSelected) {
      backgroundColor = Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.10);
      borderSide = BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 2,
      );
      trailingIcon = Icon(
        Icons.radio_button_checked,
        color: Theme.of(context).colorScheme.primary,
      );
    } else {
      trailingIcon = Icon(
        Icons.radio_button_unchecked,
        color: Theme.of(context).colorScheme.outline,
      );
    }

    return Card(
      elevation: isSelected ? 1 : 0,
      color: backgroundColor ?? Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.medium,
        side: borderSide,
      ),
      child: InkWell(
        onTap: isSubmitted ? null : () => _handleOptionSelect(optionIndex),
        borderRadius: AppRadii.medium,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.medium,
            vertical: AppSpacing.medium,
          ),
          child: Row(
            children: [
              Expanded(
                child: Directionality(
                  textDirection: question.areOptionsUrdu
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: Text(
                    optionText,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected || (isSubmitted && isCorrect)
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSubmitted && !isCorrect && !isSelected
                          ? AppColors.mutedLight
                          : null,
                    ),
                  ),
                ),
              ),
              trailingIcon,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackBanner(
    BuildContext context,
    PracticeQuestion question,
    bool isUrdu,
  ) {
    final selectedIndex = _session!.selectedOptionIndex!;
    final isCorrect = selectedIndex == question.correctIndex;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.withValues(alpha: 0.10)
            : Colors.red.withValues(alpha: 0.10),
        borderRadius: AppRadii.medium,
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
              ),
              const SizedBox(width: AppSpacing.small),
              Text(
                isCorrect
                    ? (isUrdu ? 'درست جواب! شاباش۔' : 'Correct! Well done.')
                    : (isUrdu ? 'غلط جواب!' : 'Incorrect!'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isCorrect
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                ),
              ),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: AppSpacing.xSmall),
            Text(
              isUrdu
                  ? 'درست جواب: "${question.correctAnswer}"'
                  : 'Correct answer: "${question.correctAnswer}"',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
          if (question.explanationUrdu != null ||
              question.explanationEnglish != null) ...[
            const SizedBox(height: AppSpacing.xSmall),
            Text(
              isUrdu
                  ? (question.explanationUrdu ?? question.explanationEnglish!)
                  : (question.explanationEnglish ?? question.explanationUrdu!),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withValues(alpha: 0.85),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PracticeResultsView extends StatelessWidget {
  const _PracticeResultsView({
    required this.session,
    required this.isUrdu,
    required this.onRetry,
    required this.onBack,
  });

  final QuizSession session;
  final bool isUrdu;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final score = session.score;
    final total = session.totalQuestions;
    final percentage = session.percentage.round();

    final (headline, message, iconColor) = percentage >= 80
        ? (
            isUrdu ? 'بہترین کارکردگی! 🎉' : 'Outstanding! 🎉',
            isUrdu
                ? 'آپ نے زبردست کارکردگی کا مظاہرہ کیا۔ جاری رکھیں!'
                : 'Great job! You have mastered this lesson.',
            Colors.amber.shade700,
          )
        : percentage >= 50
        ? (
            isUrdu ? 'اچھی کوشش! 👍' : 'Good Effort! 👍',
            isUrdu
                ? 'آپ کی کوشش قابل تحسین ہے۔ مزید مشق سے اسکور بہتر کریں۔'
                : 'Good work! A bit more practice will make it perfect.',
            Theme.of(context).colorScheme.primary,
          )
        : (
            isUrdu ? 'مزید مشق کی ضرورت ہے 💪' : 'Keep Practicing 💪',
            isUrdu
                ? 'گھبرائیں نہیں! دوبارہ کوشش کریں اور اپنی غلطیوں سے سیکھیں۔'
                : 'Do not worry! Try again and learn from your mistakes.',
            Colors.orange.shade800,
          );

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.large),
      children: [
        const SizedBox(height: AppSpacing.large),
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              percentage >= 80
                  ? Icons.emoji_events_outlined
                  : Icons.auto_awesome_outlined,
              size: 56,
              color: iconColor,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        Text(
          headline,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.xSmall),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedLight),
        ),
        const SizedBox(height: AppSpacing.xLarge),

        // Score summary card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              children: [
                Text(
                  '$percentage%',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  isUrdu ? 'درستگی کا تناسب' : 'Accuracy',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.mutedLight),
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      label: isUrdu ? 'کل سوالات' : 'Total',
                      value: '$total',
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    _buildStatItem(
                      context,
                      label: isUrdu ? 'درست' : 'Correct',
                      value: '$score',
                      color: Colors.green,
                    ),
                    _buildStatItem(
                      context,
                      label: isUrdu ? 'غلط' : 'Incorrect',
                      value: '${total - score}',
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xLarge),

        // Buttons
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(isUrdu ? 'دوبارہ کوئز کھیلیں' : 'Retry Quiz'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: AppRadii.medium),
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        OutlinedButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
          label: Text(isUrdu ? 'پریکٹس پر واپس جائیں' : 'Back to Practice'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: AppRadii.medium),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    Color? color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.mutedLight),
        ),
      ],
    );
  }
}
