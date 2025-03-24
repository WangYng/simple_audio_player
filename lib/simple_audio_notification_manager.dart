import 'dart:collection';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:simple_audio_player/simple_audio_player.dart';
import 'package:simple_audio_player/simple_audio_player_api.dart';

enum SimpleAudioNotificationType {
  onPlay,
  onPause,
  onSkipToNext,
  onSkipToPrevious,
  onStop,
}

class _NotificationData {
  final SimpleAudioPlayer player;
  final String title;
  final String artist;
  final String clipArt;

  _NotificationData(this.player, this.title, this.artist, this.clipArt);
}

class SimpleAudioNotificationManager {
  static SimpleAudioNotificationManager? _instance;

  SimpleAudioNotificationManager._internal();

  factory SimpleAudioNotificationManager() => _instance ?? SimpleAudioNotificationManager._internal();

  // 缓存的图片
  Map<String, String> imageBase64Cache = HashMap();

  _NotificationData? _notificationData;

  bool get isShow => _notificationData != null;

  // 事件通知
  Stream<SimpleAudioNotificationType> eventStream = SimpleAudioPlayerApi.notificationStream.map((event) {
    if (event == "onPlay") {
      return SimpleAudioNotificationType.onPlay;
    } else if (event == "onPause") {
      return SimpleAudioNotificationType.onPause;
    } else if (event == "onSkipToNext") {
      return SimpleAudioNotificationType.onSkipToNext;
    } else if (event == "onSkipToPrevious") {
      return SimpleAudioNotificationType.onSkipToPrevious;
    } else if (event == "onStop") {
      return SimpleAudioNotificationType.onStop;
    } else {
      return SimpleAudioNotificationType.onStop;
    }
  });

  // 显示通知
  Future<void> showNotification(
      {required SimpleAudioPlayer player, required String title, required String artist, required String clipArt}) {
    _notificationData = _NotificationData(player, title, artist, clipArt);

    if (imageBase64Cache.containsKey(clipArt)) {
      final base64Image = imageBase64Cache[clipArt] ?? "";
      return SimpleAudioPlayerApi.showNotification(playerId: player.playerId, title: title, artist: artist, clipArt: base64Image);
    }

    // 从图片缓存中加载图片
    final NetworkImage imageProvider = NetworkImage(clipArt);
    final ImageStream stream = imageProvider.resolve(ImageConfiguration.empty);
    stream.addListener(ImageStreamListener((ImageInfo info, bool synchronous) async {
      final byteData = await info.image.toByteData(format: ImageByteFormat.png);
      if (byteData != null) {
        imageBase64Cache.clear();
        imageBase64Cache[clipArt] = base64Encode(byteData.buffer.asUint8List());

        // 图片加载完成，更新通知
        updateNotification();
      }
    }));

    return SimpleAudioPlayerApi.showNotification(playerId: player.playerId, title: title, artist: artist, clipArt: "");
  }

  // 更新通知
  Future<void> updateNotification() async {
    if (_notificationData != null) {
      final player = _notificationData!.player;
      final title = _notificationData!.title;
      final artist = _notificationData!.artist;
      final clipArt = _notificationData!.clipArt;

      return showNotification(player: player, title: title, artist: artist, clipArt: clipArt);
    }
  }

  // 取消通知
  Future<void> cancelNotification() {
    _notificationData = null;

    return SimpleAudioPlayerApi.cancelNotification();
  }
}
