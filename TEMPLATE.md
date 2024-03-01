
Stream songStateStream;

Stream audioFocusStream;

Stream notificationStream;

Stream becomingNoisyStream;

Future<void> init(int playerId);

Future<void> prepare(int playerId, String uri);

Future<void> play(int playerId);

Future<void> pause(int playerId);

Future<void> stop(int playerId);

Future<void> seekTo(int playerId, int position);

Future<void> setVolume(int playerId, double volume);

Future<void> setPlaybackRate(int playerId, double playbackRate);

Future<int> getCurrentPosition(int playerId);

Future<int> getDuration(int playerId);

Future<double> getPlaybackRate(int playerId);

Future<bool> tryToGetAudioFocus();

Future<void> giveUpAudioFocus();

Future<void> showNotification(int playerId, String title,  String artist,  String clipArt);

Future<void> cancelNotification();