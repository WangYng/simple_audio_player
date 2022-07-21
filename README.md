# simple_audio_player

A simple audio player for Flutter.

## Install Started

1. Add this to your **pubspec.yaml** file:

```yaml
dependencies:
  simple_audio_player: ^0.1.2
```

2. Install it

```bash
$ flutter packages get
```

## Normal usage

```dart
  @override
  void initState() {
    super.initState();

    simpleAudioPlayer = SimpleAudioPlayer();
    simpleAudioPlayer.songStateStream.listen((event) {
      print("song event : $event");
    });
    focusManager.audioFocusStream.listen((event) {
      print("focus event : $event");
    });
    focusManager.becomingNoisyStream.listen((event) {
      print("becoming noisy event : $event");
    });
    notificationManager.notificationStream.listen((event) {
      print("notification event : $event");
    });
  }

  // ...

  CupertinoButton(
    child: Text("requestAudioFocus"),
    onPressed: () {
      SimpleAudioFocusManager().tryToGetAudioFocus().then((value) {
        print("tryToGetAudioFocus $value");
      });
    },
  ),
  CupertinoButton(
    child: Text("giveUpAudioFocus"),
    onPressed: () {
      SimpleAudioFocusManager().giveUpAudioFocus();
    },
  ),
  CupertinoButton(
    child: Text("prepare"),
    onPressed: () {
      simpleAudioPlayer.prepare(
          uri: "https://96.f.1ting.com/local_to_cube_202004121813/96kmp3/2021/04/16/16b_am/01.mp3");
    },
  ),
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
```

## Feature
- [x] audio focus manager
- [x] play online mp3 file
- [x] play local mp3 file
- [x] play assets mp3 file
- [x] audio notification manager
- [x] observe becoming noisy
