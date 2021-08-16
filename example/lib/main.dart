import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_audio_player/simple_audio_focus_manager.dart';
import 'package:simple_audio_player/simple_audio_player.dart';
import 'package:simple_audio_player/simple_audio_notification_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SimpleAudioPlayer simpleAudioPlayer;
  final focusManager = SimpleAudioFocusManager();
  final notificationManager = SimpleAudioNotificationManager();


  double sliderValue = 0;

  File? file;

  @override
  void initState() {
    super.initState();

    // copy file
    Future.microtask(() async {
      File file = File("${(await getTemporaryDirectory()).path}/audios/01.mp3");

      if (!file.existsSync()) {
        file.createSync(recursive: true);
        final byteData = await rootBundle.load("audios/01.mp3");
        await file.writeAsBytes(byteData.buffer.asUint8List());
      }

      setState(() {
        this.file = file;
      });
    });

    simpleAudioPlayer = SimpleAudioPlayer();
    simpleAudioPlayer.songStateStream.listen((event) {
      print("song event : $event");
    });
    focusManager.audioFocusStream.listen((event) {
      print("focus event : $event");
    });
    focusManager.becomingNoisyStream.listen((event) {
      print("noisy event : $event");
    });
    notificationManager.notificationStream.listen((event) {
      print("notification event : $event");
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
                    CupertinoButton(
                      child: Text(
                        "prepare\nurl",
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () => simpleAudioPlayer.prepare(
                          uri: "https://96.f.1ting.com/local_to_cube_202004121813/96kmp3/2021/04/16/16b_am/01.mp3"),
                    ),
                    CupertinoButton(
                      child: Text(
                        "prepare\nasset",
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () => simpleAudioPlayer.prepare(uri: "asset:///audios/01.mp3"),
                    ),
                    CupertinoButton(
                      child: Text(
                        "prepare\nfile",
                        textAlign: TextAlign.center,
                      ),
                      onPressed: file == null ? null : () => simpleAudioPlayer.prepare(uri: "file://${file?.path}"),
                    ),
                  ],
                ),
                CupertinoButton(
                  child: Text("play"),
                  onPressed: () => simpleAudioPlayer.play(),
                ),
                CupertinoButton(
                  child: Text("pause"),
                  onPressed: () => simpleAudioPlayer.pause(),
                ),
                CupertinoButton(
                  child: Text("stop"),
                  onPressed: () => simpleAudioPlayer.stop(),
                ),
                CupertinoSlider(
                  value: sliderValue,
                  onChanged: (changeValue) {
                    setState(() {
                      sliderValue = changeValue;
                    });
                  },
                  onChangeEnd: (changeValue) async {
                    final duration = await simpleAudioPlayer.getDuration();
                    simpleAudioPlayer.seekTo(position: (duration * changeValue).toInt());
                  },
                ),
                CupertinoButton(
                  child: Text("showNotification"),
                  onPressed: () => notificationManager.showNotification(title: "title", artist: "artist", clipArt: ""),
                ),
                CupertinoButton(
                  child: Text("updateNotification"),
                  onPressed: () => notificationManager.updateNotification(showPlay: false, title: "update", artist: "update", clipArt: ""),
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
