import 'package:simple_audio_player/simple_audio_player_api.dart';

class SimpleAudioNotificationManager {

  static SimpleAudioNotificationManager? _instance;

  SimpleAudioNotificationManager._internal();

  factory SimpleAudioNotificationManager() => _instance ?? SimpleAudioNotificationManager._internal();

  Stream notificationStream = SimpleAudioPlayerApi.notificationStream;

  Future<void> showNotification({required String title, required String artist, required String clipArt}) {
    return SimpleAudioPlayerApi.showNotification(title: title, artist: artist, clipArt: clipArt);
  }

  Future<void> updateNotification({required bool showPlay, required String title, required String artist, required String clipArt}) {
    return SimpleAudioPlayerApi.updateNotification(showPlay: showPlay, title: title, artist: artist, clipArt: clipArt);
  }

  Future<void> cancelNotification() {
    return SimpleAudioPlayerApi.cancelNotification();
  }
}