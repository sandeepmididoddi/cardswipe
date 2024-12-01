import 'package:card_swipe/models/game_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;
  final Difficulty difficulty;
  final ThemeMode themeMode;

  const GameSettings({
    required this.soundEnabled,
    required this.musicEnabled,
    required this.vibrationEnabled,
    required this.difficulty,
    required this.themeMode,
  });
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, GameSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});

class SettingsNotifier extends StateNotifier<GameSettings> {
  final SharedPreferences prefs;

  SettingsNotifier(this.prefs)
      : super(const GameSettings(
          soundEnabled: true,
          musicEnabled: true,
          vibrationEnabled: true,
          difficulty: Difficulty.medium,
          themeMode: ThemeMode.system,
        ));

  Future<void> toggleSound() async {
    state = GameSettings(
      soundEnabled: !state.soundEnabled,
      musicEnabled: state.musicEnabled,
      vibrationEnabled: state.vibrationEnabled,
      difficulty: state.difficulty,
      themeMode: state.themeMode,
    );
    await prefs.setBool('soundEnabled', state.soundEnabled);
  }
}
