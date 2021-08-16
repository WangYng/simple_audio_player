import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class SimpleAudioPlayerApi {

  static Stream songStateStream = EventChannel("io.github.wangyng.simple_audio_player/songStateStream").receiveBroadcastStream();

  static Stream audioFocusStream = EventChannel("io.github.wangyng.simple_audio_player/audioFocusStream").receiveBroadcastStream();

  static Stream notificationStream = EventChannel("io.github.wangyng.simple_audio_player/notificationStream").receiveBroadcastStream();

  static Stream becomingNoisyStream = EventChannel("io.github.wangyng.simple_audio_player/becomingNoisyStream").receiveBroadcastStream();

  static Future<void> init({required int playerId}) async {
    const channel = BasicMessageChannel<dynamic>('io.github.wangyng.simple_audio_player.init', StandardMessageCodec());

    final Map<String, dynamic> requestMap = {};
    requestMap["playerId"] = playerId;
    final reply = await channel.send(requestMap);

    if (!(reply is Map)) {
      _throwChannelException();
    }

    final replyMap = Map<String, dynamic>.from(reply);
    if (replyMap['error'] != null) {
      final error = Map<String, dynamic>.from(replyMap['error']);
      _throwException(error);
      
    } else {
      // noop
    }
  }

  static Future<void> prepare({required int playerId, required String uri}) async {
    const channel = BasicMessageChannel<dynamic>('io.github.wangyng.simple_audio_player.prepare', StandardMessageCodec());

    final Map<String, dynamic> requestMap = {};
    requestMap["playerId"] = playerId;
    requestMap["uri"] = uri;
    final reply = await channel.send(requestMap);

    if (!(reply is Map)) {
      _throwChannelException();
    }

    final replyMap = Map<String, dynamic>.from(reply);
    if (replyMap['error'] != null) {
      final error = Map<String, dynamic>.from(replyMap['error']);
      _throwException(error);
      
    } else {
      // noop
    }
  }

  static Future<void> play({required int playerId}) async {
    const channel = BasicMessageChannel<dynamic>('io.github.wangyng.simple_audio_player.play', StandardMessageCodec());

    final Map<String, dynamic> requestMap = {};
    requestMap["playerId"] = playerId;
    final reply = await channel.send(requestMap);

    if (!(reply is Map)) {
      _throwChannelException();
    }

    final replyMap = Map<String, dynamic>.from(reply);
    if (replyMap['error'] != null) {
      final error = Map<String, dynamic>.from(replyMap['error']);
      _throwException(error);
      
    } else {
      // noop
    }
  }

  static Future<void> pause({required int playerId}) async {
    const channel = BasicMessageChannel<dynamic>('io.github.wangyng.simple_audio_player.pause', StandardMessageCodec());

    final Map<String, dynamic> requestMap = {};
    requestMap["playerId"] = playerId;
    final reply = await channel.send(requestMap);

    if (!(reply is Map)) {
      _throwChannelException();
    }

    final replyMap = Map<String, dynamic>.from(reply);
    if (replyMap['error'] != null) {
      final error = Map<String, dynamic>.from(replyMap['error']);
      _throwException(error);
      
    } else {
      // noop
    }
  }

  static Future<void> stop({required int playerId}) async {
    const channel = BasicMessageChannel<dynamic>('io.github.wangyng.simple_audio_player.stop', StandardMessageCodec());

    final Map<String, dynamic> requestMap = {};
    requestMap["playerId"] = playerId;
    final reply = await channel.send(requestMap);

    if (!(reply is Map)) {
      _throwChannelException();
    }

    final replyMap = Map<String, dynamic>.from(reply);
    if (replyMap['error'] != null) {
      final error = Map<String, dynamic>.from(replyMap['error']);
      _throwException(error);
      
    } else {
      // noop
    }
  }

  static Future<void> seekTo({required int playerId, required int position}) async {
    const channel = BasicMessageChannel<dynamic>('io.github.wangyng.simple_audio_player.seekTo', StandardMessageCodec());

    final Map<String, dynamic> requestMap = {};
    requestMap["playerId"] = playerId;
    requestMap["position"] = position;
    final reply = await channel.send(requestMap);

    if (!(reply is Map)) {
      _throwChannelException();
    }

    final replyMap = Map<String, dynamic>.from(reply);
    if (replyMap['error'] != null) {
      final error = Map<String, dynamic>.from(replyMap['error']);
      _throwException(error);
      
    } else {
      // noop
    }
  }

  static Future<int> getCurrentPosition({required int playerId}) async {
    const channel = BasicMessageChannel<dynamic>('io.github.wangyng.simple_audio_player.getCurrentPosition', StandardMessageCodec());

    final Map<String, dynamic> requestMap = {};
    requestMap["playerId"] = playerId;
    final reply = await channel.send(requestMap);

    if (!(reply is Map)) {
      _throwChannelException();
    }

    final replyMap = Map<String, dynamic>.from(reply);
    if (replyMap['error'] != null) {
      final error = Map<String, dynamic>.from(replyMap['error']);
      _throwException(error);
      return 0;
    } else {
      return replyMap["result"];
    }
  }

  static Future<int> getDuration({required int playerId}) async {
    const channel = BasicMessageChannel<dynamic>('io.github.wangyng.simple_audio_player.getDuration', StandardMessageCodec());

    final Map<String, dynamic> requestMap = {};
    requestMap["playerId"] = playerId;
    final reply = await channel.send(requestMap);

    if (!(reply is Map)) {
      _throwChannelException();
    }

    final replyMap = Map<String, dynamic>.from(reply);
    if (replyMap['error'] != null) {
      final error = Map<String, dynamic>.from(replyMap['error']);
      _throwException(error);
      return 0;
    } else {
      return replyMap["result"];
    }
  }

  static Future<bool> tryToGetAudioFocus() async {
    const channel = BasicMessageChannel<dynamic>('io.github.wangyng.simple_audio_player.tryToGetAudioFocus', StandardMessageCodec());

    final Map<String, dynamic> requestMap = {};
    final reply = await channel.send(requestMap);

    if (!(reply is Map)) {
      _throwChannelException();
    }

    final replyMap = Map<String, dynamic>.from(reply);
    if (replyMap['error'] != null) {
      final error = Map<String, dynamic>.from(replyMap['error']);
      _throwException(error);
      return false;
    } else {
      return replyMap["result"];
    }
  }

  static Future<void> giveUpAudioFocus() async {
    const channel = BasicMessageChannel<dynamic>('io.github.wangyng.simple_audio_player.giveUpAudioFocus', StandardMessageCodec());

    final Map<String, dynamic> requestMap = {};
    final reply = await channel.send(requestMap);

    if (!(reply is Map)) {
      _throwChannelException();
    }

    final replyMap = Map<String, dynamic>.from(reply);
    if (replyMap['error'] != null) {
      final error = Map<String, dynamic>.from(replyMap['error']);
      _throwException(error);
      
    } else {
      // noop
    }
  }

  static Future<void> showNotification({required String title, required String artist, required String clipArt}) async {
    const channel = BasicMessageChannel<dynamic>('io.github.wangyng.simple_audio_player.showNotification', StandardMessageCodec());

    final Map<String, dynamic> requestMap = {};
    requestMap["title"] = title;
    requestMap["artist"] = artist;
    requestMap["clipArt"] = clipArt;
    final reply = await channel.send(requestMap);

    if (!(reply is Map)) {
      _throwChannelException();
    }

    final replyMap = Map<String, dynamic>.from(reply);
    if (replyMap['error'] != null) {
      final error = Map<String, dynamic>.from(replyMap['error']);
      _throwException(error);
      
    } else {
      // noop
    }
  }

  static Future<void> updateNotification({required bool showPlay, required String title, required String artist, required String clipArt}) async {
    const channel = BasicMessageChannel<dynamic>('io.github.wangyng.simple_audio_player.updateNotification', StandardMessageCodec());

    final Map<String, dynamic> requestMap = {};
    requestMap["showPlay"] = showPlay;
    requestMap["title"] = title;
    requestMap["artist"] = artist;
    requestMap["clipArt"] = clipArt;
    final reply = await channel.send(requestMap);

    if (!(reply is Map)) {
      _throwChannelException();
    }

    final replyMap = Map<String, dynamic>.from(reply);
    if (replyMap['error'] != null) {
      final error = Map<String, dynamic>.from(replyMap['error']);
      _throwException(error);
      
    } else {
      // noop
    }
  }

  static Future<void> cancelNotification() async {
    const channel = BasicMessageChannel<dynamic>('io.github.wangyng.simple_audio_player.cancelNotification', StandardMessageCodec());

    final Map<String, dynamic> requestMap = {};
    final reply = await channel.send(requestMap);

    if (!(reply is Map)) {
      _throwChannelException();
    }

    final replyMap = Map<String, dynamic>.from(reply);
    if (replyMap['error'] != null) {
      final error = Map<String, dynamic>.from(replyMap['error']);
      _throwException(error);
      
    } else {
      // noop
    }
  }

}

_throwChannelException() {
  throw PlatformException(code: 'channel-error', message: 'Unable to establish connection on channel.', details: null);
}

_throwException(Map<String, dynamic> error) {
  throw PlatformException(code: "${error['code']}", message: "${error['message']}", details: "${error['details']}");
}
