import 'package:simple_audio_player/simple_audio_player_api.dart';

enum SimpleAudioFocusState {
  audioFocused,
  audioNoFocus,
}

class SimpleAudioFocusManager {
  static SimpleAudioFocusManager? _instance;

  SimpleAudioFocusManager._internal();

  factory SimpleAudioFocusManager() => _instance ?? SimpleAudioFocusManager._internal();

  Stream<SimpleAudioFocusState> audioFocusStream =
      SimpleAudioPlayerApi.audioFocusStream.map<SimpleAudioFocusState>((event) {
    if (event == "audioFocused") {
      return SimpleAudioFocusState.audioFocused;
    } else if (event == "audioFocused") {
      return SimpleAudioFocusState.audioNoFocus;
    } else {
      return SimpleAudioFocusState.audioNoFocus;
    }
  });

  Stream becomingNoisyStream = SimpleAudioPlayerApi.becomingNoisyStream;

  Future<bool> tryToGetAudioFocus() async {
    return SimpleAudioPlayerApi.tryToGetAudioFocus();
  }

  Future<void> giveUpAudioFocus() async {
    return SimpleAudioPlayerApi.giveUpAudioFocus();
  }
}
