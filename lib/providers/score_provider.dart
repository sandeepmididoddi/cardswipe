import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final scoreProvider = StateNotifierProvider<ScoreNotifier, ScoreState>((ref) {
  return ScoreNotifier(ref.read(sharedPreferencesProvider));
});

class ScoreState {
  final int highScore;
  final List<({int score, DateTime date})> recentScores;
  
  ScoreState({
    required this.highScore,
    required this.recentScores,
  });
}

class ScoreNotifier extends StateNotifier<ScoreState> {
  final SharedPreferences prefs;

  ScoreNotifier(this.prefs) : super(ScoreState(
    highScore: 0,
    recentScores: [],
  ));
  
  Future<void> saveScore(int score) async {
    if (score > state.highScore) {
      await prefs.setInt('highScore', score);
      state = ScoreState(
        highScore: score,
        recentScores: [...state.recentScores, (score: score, date: DateTime.now())]
      );
    }
  }
}
