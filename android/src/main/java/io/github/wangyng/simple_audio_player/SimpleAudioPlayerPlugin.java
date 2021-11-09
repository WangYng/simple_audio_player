package io.github.wangyng.simple_audio_player;

import android.content.Context;
import android.net.Uri;

import androidx.annotation.NonNull;

import org.jetbrains.annotations.NotNull;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.github.wangyng.simple_audio_player.player.AudioFocusManager;
import io.github.wangyng.simple_audio_player.player.AudioNotificationManager;
import io.github.wangyng.simple_audio_player.player.ExoPlayerManager;
import io.github.wangyng.simple_audio_player.player.PlayerManager;
import io.github.wangyng.simple_audio_player.player.Song;


public class SimpleAudioPlayerPlugin implements FlutterPlugin, SimpleAudioPlayerApi, AudioFocusManager.AudioFocusChangeCallback {

    Map<Integer, PlayerManager> playerManagerMap = new HashMap<>();
    SimpleAudioPlayerEventSink songStateStream;

    AudioFocusManager audioFocusManager;
    SimpleAudioPlayerEventSink audioFocusStream;

    AudioNotificationManager audioNotificationManager;
    SimpleAudioPlayerEventSink notificationStream;

    SimpleAudioPlayerEventSink becomingNoisyStream;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        SimpleAudioPlayerApi.setup(binding, this, binding.getApplicationContext());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        SimpleAudioPlayerApi.setup(binding, null, null);
    }

    @Override
    public void setSongStateStream(Context context, SimpleAudioPlayerEventSink songStateStream) {
        this.songStateStream = songStateStream;
    }

    @Override
    public void setAudioFocusStream(Context context, SimpleAudioPlayerEventSink audioFocusStream) {
        this.audioFocusStream = audioFocusStream;
    }

    @Override
    public void setNotificationStream(Context context, SimpleAudioPlayerEventSink notificationStream) {
        this.notificationStream = notificationStream;
    }

    @Override
    public void setBecomingNoisyStream(Context context, SimpleAudioPlayerEventSink becomingNoisyStream) {
        this.becomingNoisyStream = becomingNoisyStream;
    }

    @Override
    public void init(Context context, int playerId) {
        PlayerManager player = new ExoPlayerManager(context);
        player.setCallback(new PlayerManager.SongStateCallback() {
            @Override
            public void onReady() {
                if (songStateStream != null && songStateStream.event != null) {
                    Map<String, Object> result = new HashMap<>();
                    result.put("playerId", playerId);
                    result.put("event", "onReady");
                    result.put("data", new long[]{player.getCurrentPosition(), player.getDuration()});
                    songStateStream.event.success(result);
                }
            }

            @Override
            public void onPlayEnd() {
                if (songStateStream != null && songStateStream.event != null) {
                    Map<String, Object> result = new HashMap<>();
                    result.put("playerId", playerId);
                    result.put("event", "onPlayEnd");
                    songStateStream.event.success(result);
                }
            }

            @Override
            public void onError(@NotNull String message) {
                if (songStateStream != null && songStateStream.event != null) {
                    Map<String, Object> result = new HashMap<>();
                    result.put("playerId", playerId);
                    result.put("event", "onError");
                    result.put("data", message);
                    songStateStream.event.success(result);
                }
            }

            @Override
            public void onPositionChange(long position, long duration) {
                if (songStateStream != null && songStateStream.event != null) {
                    Map<String, Object> result = new HashMap<>();
                    result.put("playerId", playerId);
                    result.put("event", "onPositionChange");
                    result.put("data", new long[]{position, duration});
                    songStateStream.event.success(result);
                }
            }
        });
        playerManagerMap.put(playerId, player);

    }

    @Override
    public void prepare(Context context, int playerId, String uri) {
        PlayerManager player = playerManagerMap.get(playerId);
        player.prepare(Uri.parse(uri));
    }

    @Override
    public void play(Context context, int playerId) {
        PlayerManager player = playerManagerMap.get(playerId);
        player.play();
    }

    @Override
    public void pause(Context context, int playerId) {
        PlayerManager player = playerManagerMap.get(playerId);
        player.pause();
    }

    @Override
    public void stop(Context context, int playerId) {
        PlayerManager player = playerManagerMap.get(playerId);
        player.stop();
    }

    @Override
    public void seekTo(Context context, int playerId, Long position) {
        PlayerManager player = playerManagerMap.get(playerId);
        player.seekTo(position);
    }

    @Override
    public Long getCurrentPosition(Context context, int playerId) {
        PlayerManager player = playerManagerMap.get(playerId);
        return player.getCurrentPosition();
    }

    @Override
    public Long getDuration(Context context, int playerId) {
        PlayerManager player = playerManagerMap.get(playerId);
        return player.getDuration();
    }

    @Override
    public boolean tryToGetAudioFocus(Context context) {
        if (audioFocusManager == null) {
            audioFocusManager = new AudioFocusManager(context);
        }
        return audioFocusManager.tryToGetAudioFocus(this);
    }

    @Override
    public void giveUpAudioFocus(Context context) {
        if (audioFocusManager != null) {
            audioFocusManager.giveUpAudioFocus();
        }
    }

    @Override
    public void onAudioFocused() {
        if (audioFocusStream.event != null) {
            audioFocusStream.event.success("audioFocused");
        }
    }

    @Override
    public void onAudioNoFocus() {
        if (audioFocusStream.event != null) {
            audioFocusStream.event.success("audioNoFocus");
        }
    }

    @Override
    public void onAudioBecomingNoisy() {
        if (becomingNoisyStream.event != null) {
            becomingNoisyStream.event.success("becomingNoisy");
        }
    }

    @Override
    public void showNotification(Context context, String title, String artist, String clipArt) {
        if (audioNotificationManager == null) {
            audioNotificationManager = new AudioNotificationManager(context);
            audioNotificationManager.setCallback(new AudioNotificationManager.AudioNotificationEventCallback() {
                @Override
                public void onReceivePlay() {
                    if (notificationStream.event != null) {
                        notificationStream.event.success("onPlay");
                    }
                }

                @Override
                public void onReceivePause() {
                    if (notificationStream.event != null) {
                        notificationStream.event.success("onPause");
                    }
                }

                @Override
                public void onReceiveSkipToNext() {
                    if (notificationStream.event != null) {
                        notificationStream.event.success("onSkipToNext");
                    }
                }

                @Override
                public void onReceiveSkipToPrevious() {
                    if (notificationStream.event != null) {
                        notificationStream.event.success("onSkipToPrevious");
                    }
                }

                @Override
                public void onReceiveStop() {
                    if (notificationStream.event != null) {
                        notificationStream.event.success("onStop");
                    }
                }
            });
        }
        audioNotificationManager.showNotification(new Song(title, artist, clipArt));
    }

    @Override
    public void updateNotification(Context context, boolean showPlay, String title, String artist, String clipArt) {
        if (audioNotificationManager != null) {
            audioNotificationManager.updateNotification(showPlay, new Song(title, artist, clipArt));
        }
    }

    @Override
    public void cancelNotification(Context context) {
        if (audioNotificationManager != null) {
            audioNotificationManager.cancelNotification();
            audioNotificationManager = null;
        }
    }
}
