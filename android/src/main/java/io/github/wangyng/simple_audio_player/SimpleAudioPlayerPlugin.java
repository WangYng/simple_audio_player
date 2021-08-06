package io.github.wangyng.simple_audio_player;

import android.content.Context;
import android.net.Uri;

import androidx.annotation.NonNull;

import org.jetbrains.annotations.NotNull;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.github.wangyng.simple_audio_player.player.ExoPlayerManager;
import io.github.wangyng.simple_audio_player.player.PlayerManager;
import io.github.wangyng.simple_audio_player.player.Song;


public class SimpleAudioPlayerPlugin implements FlutterPlugin, SimpleAudioPlayerApi {

    Map<Integer, PlayerManager> playerManagerMap = new HashMap<>();
    SimpleAudioPlayerEventSink songStateStream;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        SimpleAudioPlayerApi.setup(binding.getBinaryMessenger(), this, binding.getApplicationContext());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        SimpleAudioPlayerApi.setup(binding.getBinaryMessenger(), null, null);
    }

    @Override
    public void setSongStateStream(Context context, SimpleAudioPlayerEventSink songStateStream) {
        this.songStateStream = songStateStream;
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
        player.prepare(new Song(Uri.parse(uri)));
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
}
