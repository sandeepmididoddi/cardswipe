class Achievement {
  final String id;
  final String title;
  final String description;
  final int requiredScore;
  bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredScore,
    this.isUnlocked = false,
  });
}

class AchievementManager {
  static final List<Achievement> achievements = [
    Achievement(
      id: 'first_win',
      title: 'First Victory',
      description: 'Complete your first game',
      requiredScore: 100,
    ),
    Achievement(
      id: 'master_swiper',
      title: 'Master Swiper',
      description: 'Reach 1000 points in a single game',
      requiredScore: 1000,
    ),
  ];

  static void checkAchievements(int score) {
    for (var achievement in achievements) {
      if (!achievement.isUnlocked && score >= achievement.requiredScore) {
        achievement.isUnlocked = true;
        _showAchievementUnlocked(achievement);
      }
    }
  }

  static void _showAchievementUnlocked(Achievement achievement) {
    // Show achievement notification
  }
}
