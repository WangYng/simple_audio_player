
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_audio_player/simple_audio_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SimpleAudioPlayer simpleAudioPlayer;
  double sliderValue = 0;

  @override
  void initState() {
    super.initState();

    simpleAudioPlayer = SimpleAudioPlayer();
    simpleAudioPlayer.songStateStream.listen((event) {
      print("event : $event");
    });
    simpleAudioPlayer.prepare(
        uri: "https://96.f.1ting.com/local_to_cube_202004121813/96kmp3/2021/04/16/16b_am/01.mp3");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                child: Text("play"),
                onPressed: () {
                  simpleAudioPlayer.play();
                },
              ),
              CupertinoButton(
                child: Text("pause"),
                onPressed: () {
                  simpleAudioPlayer.pause();
                },
              ),
              CupertinoButton(
                child: Text("stop"),
                onPressed: () {
                  simpleAudioPlayer.stop();
                },
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
