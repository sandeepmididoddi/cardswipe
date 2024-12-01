enum Difficulty { easy, medium, hard }

class GameConfig {
  final Difficulty difficulty;
  final int pointsPerUpSwipe;
  final int pointsCostPerDownSwipe;
  final double timeLimit;
  
  const GameConfig._({
    required this.difficulty,
    required this.pointsPerUpSwipe,
    required this.pointsCostPerDownSwipe,
    required this.timeLimit,
  });

  factory GameConfig.forDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return GameConfig._(
          difficulty: difficulty,
          pointsPerUpSwipe: 5,
          pointsCostPerDownSwipe: 10,
          timeLimit: 120,
        );
      case Difficulty.medium:
        return GameConfig._(
          difficulty: difficulty,
          pointsPerUpSwipe: 3,
          pointsCostPerDownSwipe: 15,
          timeLimit: 90,
        );
      case Difficulty.hard:
        return GameConfig._(
          difficulty: difficulty,
          pointsPerUpSwipe: 2,
          pointsCostPerDownSwipe: 20,
          timeLimit: 60,
        );
    }
  }
}
