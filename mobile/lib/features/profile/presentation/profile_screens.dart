import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/speech_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../main.dart';
import '../../../shared/widgets/app_components.dart';
import '../../auth/presentation/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider);
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final isUrdu = preferences.language == AppLanguage.urdu;

    return Scaffold(
      appBar: AppBar(title: Text(isUrdu ? 'پروفائل' : 'Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          const Center(child: AppLogo(height: 72)),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'English Udaan',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.large),
          if (user != null) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(user.email),
                subtitle: Text(
                  isUrdu ? 'آپ کا اکاؤنٹ' : 'Your account',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Card(
              child: ListTile(
                leading: const Icon(Icons.cloud_outlined),
                title: Text(isUrdu ? 'کلاؤڈ میں محفوظ' : 'Saved to cloud'),
                subtitle: Text(
                  isUrdu
                      ? 'آپ کی پیش رفت کلاؤڈ میں ہے۔'
                      : 'Your progress is synced to cloud.',
                ),
              ),
            ),
          ] else ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(isUrdu ? 'مقامی صارف' : 'Local learner'),
                subtitle: Text(
                  isUrdu
                      ? 'اکاؤنٹ نہیں بنایا۔ سیکھنے کی پیش رفت اسی آلے پر محفوظ رہتی ہے۔'
                      : 'No account. Learning progress stays on this device.',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Card(
              child: ListTile(
                leading: const Icon(Icons.login),
                title: Text(isUrdu ? 'لاگ ان کریں' : 'Log in'),
                subtitle: Text(
                  isUrdu
                      ? 'اپنی پیش رفت کو کلاؤڈ میں محفوظ کریں۔'
                      : 'Save your progress to the cloud.',
                ),
                onTap: () => context.go('/auth/login'),
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: Text(isUrdu ? 'لاگ آؤٹ' : 'Log out'),
                subtitle: Text(
                  isUrdu
                      ? 'لاگ ان کے بغیر لاگ آؤٹ دستیاب نہیں۔'
                      : 'Log out is unavailable without an account.',
                ),
                enabled: false,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.large),
          _SettingsTile(
            icon: Icons.language,
            title: isUrdu ? 'زبان' : 'Language',
            value: isUrdu ? 'اردو' : 'English',
            onTap: () => context.push('/settings'),
          ),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: isUrdu ? 'ظاہری انداز' : 'Appearance',
            value: _themeLabel(preferences.themeMode, isUrdu),
            onTap: () => context.push('/settings'),
          ),
          _SettingsTile(
            icon: Icons.volume_up_outlined,
            title: isUrdu ? 'آواز' : 'Audio',
            value: preferences.speechEnabled
                ? (isUrdu ? 'چالو' : 'On')
                : (isUrdu ? 'بند' : 'Off'),
            onTap: () => context.push('/settings/audio'),
          ),
          _SettingsTile(
            icon: Icons.help_outline,
            title: isUrdu ? 'مدد' : 'Help',
            onTap: () => context.push('/profile/help'),
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: isUrdu ? 'ایپ کے بارے میں' : 'About',
            onTap: () => context.push('/profile/about'),
          ),
          if (user != null) ...[
            const SizedBox(height: AppSpacing.large),
            ElevatedButton.icon(
              onPressed: () => _logout(context, ref),
              icon: const Icon(Icons.logout),
              label: Text(isUrdu ? 'لاگ آؤٹ' : 'Log out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final authService = ref.read(authServiceProvider);
    await authService.signOut();
    await ref.read(cloudProgressServiceProvider).clearActiveAccount();
    ref.invalidate(cloudProgressServiceProvider);
    if (context.mounted) {
      context.go('/auth/login');
    }
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

class AudioSettingsScreen extends ConsumerWidget {
  const AudioSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider);
    final controller = ref.read(preferencesProvider.notifier);
    final isUrdu = preferences.language == AppLanguage.urdu;
    return Scaffold(
      appBar: AppBar(title: Text(isUrdu ? 'آواز' : 'Audio')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(isUrdu ? 'انگریزی تلفظ' : 'English pronunciation'),
            subtitle: Text(
              isUrdu
                  ? 'بند کرنے پر سبق کی آواز نہیں چلے گی۔'
                  : 'Turns off lesson pronunciation.',
            ),
            value: preferences.speechEnabled,
            onChanged: controller.setSpeechEnabled,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            isUrdu ? 'بولنے کی رفتار' : 'Speech rate',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            min: SpeechPreferences.minRate,
            max: SpeechPreferences.maxRate,
            divisions: 6,
            label: preferences.speechRate.toStringAsFixed(2),
            value: preferences.speechRate,
            onChanged: preferences.speechEnabled
                ? controller.setSpeechRate
                : null,
          ),
          Text(
            isUrdu
                ? 'اگر انگریزی آواز دستیاب نہ ہو تو سبق میں موجود پیغام دکھایا جائے گا۔'
                : 'If an English voice is unavailable, lessons keep their existing message.',
          ),
        ],
      ),
    );
  }
}

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUrdu = ref.watch(preferencesProvider).language == AppLanguage.urdu;
    final topics = isUrdu ? _urduTopics : _englishTopics;
    return Scaffold(
      appBar: AppBar(title: Text(isUrdu ? 'مدد' : 'Help')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          for (final topic in topics) ...[
            Text(topic.$1, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xSmall),
            Text(topic.$2),
            const SizedBox(height: AppSpacing.medium),
          ],
        ],
      ),
    );
  }
}

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUrdu = ref.watch(preferencesProvider).language == AppLanguage.urdu;
    return Scaffold(
      appBar: AppBar(title: Text(isUrdu ? 'ایپ کے بارے میں' : 'About')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          const Center(child: AppLogo(height: 88)),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'English Udaan',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            isUrdu
                ? 'اردو بولنے والوں کے لیے انگریزی سیکھنے کی ایپ۔'
                : 'An English learning app for Urdu speakers.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.large),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(isUrdu ? 'ورژن' : 'Version'),
            subtitle: const Text(appVersionLabel),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('englishudaan.com'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null) Text(value!),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

const _englishTopics = [
  (
    'Alphabet',
    'Open Learn from Home and tap a letter to hear its English pronunciation.',
  ),
  (
    'Vocabulary',
    'Switch between two-, three-, four-, and five-letter words. Search filters the current section.',
  ),
  (
    'Pictures',
    'Choose a category, then tap a picture to hear the English word.',
  ),
  (
    'Sentences and paragraphs',
    'Read the English text and its Urdu meaning, then use the speaker button.',
  ),
  ('Grammar', 'Open a topic to read the rule, examples, and corrections.'),
  (
    'Practice',
    'Choose a quiz, select one answer, and review your score at the end.',
  ),
  (
    'Progress',
    'Completed vocabulary and picture sections, quiz scores, and study streaks stay on this device.',
  ),
  (
    'Language and appearance',
    'Settings changes Urdu or English and System, Light, or Dark appearance.',
  ),
  (
    'Pronunciation',
    'Audio settings can turn speech off or change its speed. If this device has no English voice, the lesson shows the existing message.',
  ),
];

const _urduTopics = [
  ('حروف', 'ہوم سے سیکھیں کھولیں اور حرف کو دبا کر انگریزی تلفظ سنیں۔'),
  (
    'الفاظ',
    'دو، تین، چار اور پانچ حرفی حصے بدلیں۔ تلاش صرف موجودہ حصے کو فلٹر کرتی ہے۔',
  ),
  ('تصاویر', 'زمرہ منتخب کریں، پھر تصویر دبا کر انگریزی لفظ سنیں۔'),
  (
    'جملے اور پیراگراف',
    'انگریزی متن اور اردو معنی پڑھیں، پھر اسپیکر بٹن استعمال کریں۔',
  ),
  ('گرامر', 'موضوع کھول کر قاعدہ، مثالیں اور درستگی پڑھیں۔'),
  ('پریکٹس', 'کوئز منتخب کریں، ایک جواب دیں، اور آخر میں اسکور دیکھیں۔'),
  (
    'پیش رفت',
    'مکمل الفاظ اور تصویری حصے، کوئز اسکور، اور سلسلہ اسی آلے پر محفوظ رہتے ہیں۔',
  ),
  (
    'زبان اور ظاہری انداز',
    'ترتیبات میں اردو یا انگریزی، اور سسٹم، روشن یا تاریک انداز منتخب کریں۔',
  ),
  (
    'تلفظ',
    'آواز کی ترتیبات میں تلفظ بند یا اس کی رفتار بدل سکتے ہیں۔ اگر انگریزی آواز نہ ہو تو سبق موجودہ پیغام دکھاتا ہے۔',
  ),
];
