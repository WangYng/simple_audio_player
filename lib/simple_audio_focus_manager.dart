import 'package:simple_audio_player/simple_audio_player_api.dart';

class SimpleAudioFocusManager {

  static SimpleAudioFocusManager? _instance;

  SimpleAudioFocusManager._internal();

  factory SimpleAudioFocusManager() => _instance ?? SimpleAudioFocusManager._internal();

  Stream audioFocusStream = SimpleAudioPlayerApi.audioFocusStream;

  Stream becomingNoisyStream = SimpleAudioPlayerApi.becomingNoisyStream;

  Future<bool> tryToGetAudioFocus() async {
    return SimpleAudioPlayerApi.tryToGetAudioFocus();
  }

  Future<void> giveUpAudioFocus() async {
    return SimpleAudioPlayerApi.giveUpAudioFocus();
  }
}