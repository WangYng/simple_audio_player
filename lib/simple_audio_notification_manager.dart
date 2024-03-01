import 'package:simple_audio_player/simple_audio_player.dart';
import 'package:simple_audio_player/simple_audio_player_api.dart';

enum SimpleAudioNotificationState {
  onPlay,
  onPause,
  onSkipToNext,
  onSkipToPrevious,
  onStop,
}

class SimpleAudioNotificationManager {
  static SimpleAudioNotificationManager? _instance;

  SimpleAudioNotificationManager._internal();

  factory SimpleAudioNotificationManager() => _instance ?? SimpleAudioNotificationManager._internal();

  Stream<SimpleAudioNotificationState> notificationStream = SimpleAudioPlayerApi.notificationStream.map((event) {
    if (event == "onPlay") {
      return SimpleAudioNotificationState.onPlay;
    } else if (event == "onPause") {
      return SimpleAudioNotificationState.onPause;
    } else if (event == "onSkipToNext") {
      return SimpleAudioNotificationState.onSkipToNext;
    } else if (event == "onSkipToPrevious") {
      return SimpleAudioNotificationState.onSkipToPrevious;
    } else if (event == "onStop") {
      return SimpleAudioNotificationState.onStop;
    } else {
      return SimpleAudioNotificationState.onStop;
    }
  });

  Future<void> showNotification({required SimpleAudioPlayer player, required String title, required String artist, required String clipArt}) {
    return SimpleAudioPlayerApi.showNotification(playerId: player.playerId, title: title, artist: artist, clipArt: clipArt);
  }

  Future<void> cancelNotification() {
    return SimpleAudioPlayerApi.cancelNotification();
  }
}
