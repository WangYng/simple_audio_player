import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_audio_player/simple_audio_player_api.dart';

class SimpleAudioPlayer {

  static int _firstPlayerId = 1;

  final int playerId = _firstPlayerId++;

  late Stream songStateStream;

  SimpleAudioPlayer() {
    SimpleAudioPlayerApi.init(playerId: playerId);
    songStateStream = SimpleAudioPlayerApi.songStateStream.where((event) {
      if (event is Map) {
        final playerId = int.tryParse(event["playerId"]?.toString() ?? "") ?? -1;
        return playerId == this.playerId;
      }
      return false;
    });
  }

  Future<void> prepare({required String uri}) async {
    return SimpleAudioPlayerApi.prepare(playerId: playerId, uri: uri);
  }

  Future<void> play() async {
    return SimpleAudioPlayerApi.play(playerId: playerId);
  }

  Future<void> pause() async {
    return SimpleAudioPlayerApi.pause(playerId: playerId);
  }

  Future<void> stop() async {
    return SimpleAudioPlayerApi.stop(playerId: playerId);
  }

  Future<void> seekTo({required int position}) async {
    return SimpleAudioPlayerApi.seekTo(playerId: playerId, position: position);
  }

  Future<int> getCurrentPosition() async {
    return SimpleAudioPlayerApi.getCurrentPosition(playerId: playerId);
  }

  Future<int> getDuration() async {
    return SimpleAudioPlayerApi.getDuration(playerId: playerId);
  }
}

