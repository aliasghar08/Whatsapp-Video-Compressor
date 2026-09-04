import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E1E1E),
              Color(0xFF121212),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SettingsSectionHeader(title: 'Compression'),
            SettingsSwitchTile(
              title: 'High Quality Mode',
              subtitle: 'Takes longer, but prioritizes maximum video quality.',
              value: settingsState.highQualityMode,
              onChanged: (val) => ref.read(settingsProvider.notifier).setHighQualityMode(val),
              icon: Icons.high_quality,
            ),
            const SizedBox(height: 24),
            const SettingsSectionHeader(title: 'Storage'),
            SettingsSwitchTile(
              title: 'Auto-Save to Gallery',
              subtitle: 'Automatically save the compressed video to your device.',
              value: settingsState.autoSaveToGallery,
              onChanged: (val) => ref.read(settingsProvider.notifier).setAutoSaveToGallery(val),
              icon: Icons.save_alt,
            ),
          ],
        ),
      ),
    );
  }
}
