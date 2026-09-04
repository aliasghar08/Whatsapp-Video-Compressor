import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final bool highQualityMode;
  final bool autoSaveToGallery;

  SettingsState({
    this.highQualityMode = false,
    this.autoSaveToGallery = true,
  });

  SettingsState copyWith({
    bool? highQualityMode,
    bool? autoSaveToGallery,
  }) {
    return SettingsState(
      highQualityMode: highQualityMode ?? this.highQualityMode,
      autoSaveToGallery: autoSaveToGallery ?? this.autoSaveToGallery,
    );
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    // In a real app, you would load from SharedPreferences here.
    return SettingsState();
  }

  void setHighQualityMode(bool value) {
    state = state.copyWith(highQualityMode: value);
  }

  void setAutoSaveToGallery(bool value) {
    state = state.copyWith(autoSaveToGallery: value);
  }
}
