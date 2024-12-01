import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static Future<void> initialize() async {
    await Future.wait([
      _audioPlayer.setAsset('swipe_up.mp3'),
      _audioPlayer.setAsset('swipe_down.mp3'), 
      _audioPlayer.setAsset('success.mp3'),
      _audioPlayer.setAsset('background_music.mp3'),
    ]);
  }
  static Future<void> playSwipeSound(bool isUpward) async {
    await _audioPlayer.setAsset(isUpward ? 'swipe_up.mp3' : 'swipe_down.mp3');
    await _audioPlayer.play();
  }

  static Future<void> playBackgroundMusic() async {
    await _audioPlayer.setAsset('background_music.mp3');
    await _audioPlayer.setLoopMode(LoopMode.all);
    await _audioPlayer.play();
  }
  }
