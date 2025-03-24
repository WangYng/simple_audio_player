import 'dart:async';

import 'package:simple_audio_player/simple_audio_player_api.dart';

// 播放器事件类型
enum SimpleAudioPlayerEventType {
  onReady,
  onPlayEnd,
  onError,
  onPositionChange,
}

// 播放器事件
class SimpleAudioPlayerEvent {
  final SimpleAudioPlayerEventType type;
  dynamic data;

  SimpleAudioPlayerEvent(this.type, {this.data});

  @override
  String toString() {
    return 'SimpleAudioPlayerEvent{type: $type, data: $data}';
  }
}

// 播放器状态
enum SimpleAudioPlayerState {
  idle,
  playing,
  pause,
  stop,
}

// 播放器进度
class SimpleAudioPlayerPosition {
  final Duration position;
  final Duration duration;

  SimpleAudioPlayerPosition(this.position, this.duration);

  @override
  String toString() {
    return 'SimpleAudioPlayerPosition{position: $position, duration: $duration}';
  }
}

class SimpleAudioPlayer {
  static int _firstPlayerId = 1;

  final int playerId = _firstPlayerId++;

  StreamController<SimpleAudioPlayerState> _stateController = StreamController.broadcast();

  StreamController<SimpleAudioPlayerPosition> _positionController = StreamController.broadcast();

  // 监听播放器事件
  StreamSubscription? _eventStreamSubscription;

  // 播放器事件通知
  late Stream<SimpleAudioPlayerEvent> eventStream;

  // 播放器状态通知
  Stream<SimpleAudioPlayerState> get stateStream => _stateController.stream;

  // 播放器进度通知
  Stream<SimpleAudioPlayerPosition> get positionStream => _positionController.stream;

  SimpleAudioPlayer() {
    SimpleAudioPlayerApi.init(playerId: playerId);
    eventStream = SimpleAudioPlayerApi.songStateStream.where((event) {
      if (event is Map) {
        final playerId = int.tryParse(event["playerId"]?.toString() ?? "") ?? -1;
        return playerId == this.playerId;
      }
      return false;
    }).map<SimpleAudioPlayerEvent>((event) {
      if (event["event"] == "onReady") {
        return SimpleAudioPlayerEvent(SimpleAudioPlayerEventType.onReady, data: event["data"]);
      } else if (event["event"] == "onPlayEnd") {
        return SimpleAudioPlayerEvent(SimpleAudioPlayerEventType.onPlayEnd);
      } else if (event["event"] == "onPositionChange") {
        return SimpleAudioPlayerEvent(SimpleAudioPlayerEventType.onPositionChange, data: event["data"]);
      } else if (event["event"] == "onError") {
        return SimpleAudioPlayerEvent(SimpleAudioPlayerEventType.onError, data: event["data"]);
      } else {
        return SimpleAudioPlayerEvent(SimpleAudioPlayerEventType.onError, data: event["data"]);
      }
    });

    // 监听播放器事件，更新播放器状态
    _eventStreamSubscription = eventStream.listen((event) {
      switch (event.type) {
        case SimpleAudioPlayerEventType.onReady:
          // noop
          break;
        case SimpleAudioPlayerEventType.onPlayEnd:
          _stateController.add(SimpleAudioPlayerState.stop);
          break;
        case SimpleAudioPlayerEventType.onError:
          _stateController.add(SimpleAudioPlayerState.stop);
          break;
        case SimpleAudioPlayerEventType.onPositionChange:
          final position = event.data[0];
          final duration = event.data[1];
          _positionController.add(SimpleAudioPlayerPosition(Duration(milliseconds: position), Duration(milliseconds: duration)));
          break;
      }
    });
  }

  void dispose() {
    _eventStreamSubscription?.cancel();
  }

  Future<void> prepare({required String uri}) async {
    return SimpleAudioPlayerApi.prepare(playerId: playerId, uri: uri);
  }

  Future<void> play() async {
    _stateController.add(SimpleAudioPlayerState.playing);
    return SimpleAudioPlayerApi.play(playerId: playerId);
  }

  Future<void> pause() async {
    _stateController.add(SimpleAudioPlayerState.pause);
    return SimpleAudioPlayerApi.pause(playerId: playerId);
  }

  Future<void> stop() async {
    _stateController.add(SimpleAudioPlayerState.stop);
    return SimpleAudioPlayerApi.stop(playerId: playerId);
  }

  Future<void> seekTo({required int position}) async {
    return SimpleAudioPlayerApi.seekTo(playerId: playerId, position: position);
  }

  Future<void> setVolume({required double volume}) async {
    return SimpleAudioPlayerApi.setVolume(playerId: playerId, volume: volume);
  }

  Future<void> setPlaybackRate({required double rate}) async {
    return SimpleAudioPlayerApi.setPlaybackRate(playerId: playerId, playbackRate: rate);
  }

  Future<int> getCurrentPosition() async {
    return SimpleAudioPlayerApi.getCurrentPosition(playerId: playerId);
  }

  Future<int> getDuration() async {
    return SimpleAudioPlayerApi.getDuration(playerId: playerId);
  }

  Future<double> getPlaybackRate() async {
    return SimpleAudioPlayerApi.getPlaybackRate(playerId: playerId);
  }
}
