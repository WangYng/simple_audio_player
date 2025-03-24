import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_audio_player/simple_audio_focus_manager.dart';
import 'package:simple_audio_player/simple_audio_notification_manager.dart';
import 'package:simple_audio_player/simple_audio_player.dart';

final url = "https://96.f.1ting.com/local_to_cube_202004121813/96kmp3/2021/04/16/16b_am/01.mp3";

final clipArt = "https://pics7.baidu.com/feed/a1ec08fa513d2697ebef4a6dc197c7fe4316d8b0.jpeg";

final asset = "asset:///audios/02.mp3";

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SimpleAudioPlayer player;
  final focusManager = SimpleAudioFocusManager();
  final notificationManager = SimpleAudioNotificationManager();

  double volumeValue = 1.0;

  double rateValue = 1.0;

  double sliderValue = 0;

  File? file;

  SimpleAudioPlayerState playerState = SimpleAudioPlayerState.idle;

  @override
  void initState() {
    super.initState();

    // copy file
    Future.microtask(() async {
      File file = File("${(await getTemporaryDirectory()).path}/audios/02.mp3");

      if (!file.existsSync()) {
        file.createSync(recursive: true);
        final byteData = await rootBundle.load("audios/02.mp3");
        await file.writeAsBytes(byteData.buffer.asUint8List());
      }

      setState(() {
        this.file = file;
      });
    });

    player = SimpleAudioPlayer();
    player.eventStream.listen((event) {
      print("player event : $event");
      switch (event.type) {
        case SimpleAudioPlayerEventType.onReady:
          // noop
          break;
        case SimpleAudioPlayerEventType.onPlayEnd:
          // noop
          break;
        case SimpleAudioPlayerEventType.onError:
          // noop
          break;
        case SimpleAudioPlayerEventType.onPositionChange:
          // noop
          break;
      }
    });

    player.stateStream.listen((event) {
      print("player state : $event");
      switch (event) {
        case SimpleAudioPlayerState.idle:
          // noop
          break;
        case SimpleAudioPlayerState.playing:
          // noop
          break;
        case SimpleAudioPlayerState.pause:
          // noop
          break;
        case SimpleAudioPlayerState.stop:
          // noop
          break;
      }

      setState(() {
        playerState = event;
      });
    });

    player.positionStream.listen((event) {
      print("player position : $event");

      setState(() {
        sliderValue = event.position.inMilliseconds / event.duration.inMilliseconds;
      });
    });

    focusManager.audioFocusStream.listen((event) {
      print("focus event : $event");
    });

    focusManager.becomingNoisyStream.listen((event) {
      print("noisy event : $event");
    });

    notificationManager.eventStream.listen((event) async {
      print("notification event : $event");

      switch (event) {
        case SimpleAudioNotificationType.onPlay:
          player.play();
          break;
        case SimpleAudioNotificationType.onPause:
          player.pause();
          break;
        case SimpleAudioNotificationType.onSkipToNext:
          player.seekTo(position: 0);
          player.play();
          break;
        case SimpleAudioNotificationType.onSkipToPrevious:
          player.seekTo(position: 0);
          player.play();
          break;
        case SimpleAudioNotificationType.onStop:
          player.stop();
          break;
      }

      notificationManager.updateNotification();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          constraints: BoxConstraints.expand(),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("playerState : $playerState"),
                SizedBox(height: 10),
                CupertinoButton(
                  child: Text("requestAudioFocus"),
                  onPressed: () {
                    focusManager.tryToGetAudioFocus().then((value) {
                      print("tryToGetAudioFocus $value");
                    });
                  },
                ),
                CupertinoButton(
                  child: Text("giveUpAudioFocus"),
                  onPressed: () => focusManager.giveUpAudioFocus(),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("prepare audio:"),
                    CupertinoButton(
                      child: Text("url", textAlign: TextAlign.center),
                      onPressed: () => player.prepare(uri: url),
                    ),
                    CupertinoButton(
                      child: Text("asset", textAlign: TextAlign.center),
                      onPressed: () => player.prepare(uri: asset),
                    ),
                    CupertinoButton(
                      child: Text("file", textAlign: TextAlign.center),
                      onPressed: () => player.prepare(uri: "file://${file?.path}"),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("play immediately:"),
                    CupertinoButton(
                      child: Text("url", textAlign: TextAlign.center),
                      onPressed: () {
                        player.prepare(uri: url);
                        player.setPlaybackRate(rate: rateValue);
                        player.play();
                      },
                    ),
                    CupertinoButton(
                      child: Text("asset", textAlign: TextAlign.center),
                      onPressed: () {
                        player.prepare(uri: asset);
                        player.setPlaybackRate(rate: rateValue);
                        player.play();
                      },
                    ),
                    CupertinoButton(
                      child: Text("file", textAlign: TextAlign.center),
                      onPressed: () {
                        player.prepare(uri: "file://${file?.path}");
                        player.setPlaybackRate(rate: rateValue);
                        player.play();
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoButton(
                      child: Text("play"),
                      onPressed: () {
                        player.setPlaybackRate(rate: rateValue);
                        player.play();
                        notificationManager.updateNotification();
                      },
                    ),
                    CupertinoButton(
                      child: Text("pause"),
                      onPressed: () {
                        player.pause();
                        notificationManager.updateNotification();
                      },
                    ),
                    CupertinoButton(
                      child: Text("stop"),
                      onPressed: () {
                        player.stop();
                        notificationManager.updateNotification();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("volumn: "),
                    SizedBox(width: 20),
                    CupertinoSlider(
                      value: volumeValue,
                      onChanged: (changeValue) {
                        setState(() {
                          volumeValue = changeValue;
                        });
                      },
                      onChangeEnd: (changeValue) async {
                        player.setVolume(volume: changeValue);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("rate: "),
                    SizedBox(width: 20),
                    CupertinoSlider(
                      min: 0.5,
                      max: 2,
                      value: rateValue,
                      onChanged: (changeValue) {
                        setState(() {
                          rateValue = changeValue;
                        });
                      },
                      onChangeEnd: (changeValue) async {
                        player.setPlaybackRate(rate: changeValue);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("progress: "),
                    SizedBox(width: 20),
                    CupertinoSlider(
                      value: sliderValue,
                      onChanged: (changeValue) {
                        setState(() {
                          sliderValue = changeValue;
                        });
                      },
                      onChangeEnd: (changeValue) async {
                        final duration = await player.getDuration();
                        player.seekTo(position: (duration * changeValue).toInt());
                      },
                    ),
                  ],
                ),
                CupertinoButton(
                  child: Text("showNotification"),
                  onPressed: () => notificationManager.showNotification(player: player, title: "title", artist: "artist", clipArt: clipArt),
                ),
                CupertinoButton(
                  child: Text("cancelNotification"),
                  onPressed: () => notificationManager.cancelNotification(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
