package io.github.wangyng.simple_audio_player;

import android.content.Context;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.StandardMessageCodec;

public interface SimpleAudioPlayerApi {

    void setSongStateStream(Context context, SimpleAudioPlayerEventSink songStateStream);

    void setAudioFocusStream(Context context, SimpleAudioPlayerEventSink audioFocusStream);

    void setNotificationStream(Context context, SimpleAudioPlayerEventSink notificationStream);

    void setBecomingNoisyStream(Context context, SimpleAudioPlayerEventSink becomingNoisyStream);

    void init(Context context, int playerId);

    void prepare(Context context, int playerId, String uri);

    void play(Context context, int playerId);

    void pause(Context context, int playerId);

    void stop(Context context, int playerId);

    void seekTo(Context context, int playerId, Long position);

    void setVolume(Context context, int playerId, Double volume);

    Long getCurrentPosition(Context context, int playerId);

    Long getDuration(Context context, int playerId);

    boolean tryToGetAudioFocus(Context context);

    void giveUpAudioFocus(Context context);

    void showNotification(Context context, String title, String artist, String clipArt);

    void updateNotification(Context context, boolean showPlay, String title, String artist, String clipArt);

    void cancelNotification(Context context);

    static void setup(FlutterPlugin.FlutterPluginBinding binding, SimpleAudioPlayerApi api, Context context) {
        BinaryMessenger binaryMessenger = binding.getBinaryMessenger();

        {
            EventChannel eventChannel = new EventChannel(binaryMessenger, "io.github.wangyng.simple_audio_player/songStateStream");
            SimpleAudioPlayerEventSink eventSink = new SimpleAudioPlayerEventSink();
            if (api != null) {
                eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        eventSink.event = events;
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        eventSink.event = null;
                    }
                });
                api.setSongStateStream(context, eventSink);
            } else {
                eventChannel.setStreamHandler(null);
            }
        }

        {
            EventChannel eventChannel = new EventChannel(binaryMessenger, "io.github.wangyng.simple_audio_player/audioFocusStream");
            SimpleAudioPlayerEventSink eventSink = new SimpleAudioPlayerEventSink();
            if (api != null) {
                eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        eventSink.event = events;
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        eventSink.event = null;
                    }
                });
                api.setAudioFocusStream(context, eventSink);
            } else {
                eventChannel.setStreamHandler(null);
            }
        }

        {
            EventChannel eventChannel = new EventChannel(binaryMessenger, "io.github.wangyng.simple_audio_player/notificationStream");
            SimpleAudioPlayerEventSink eventSink = new SimpleAudioPlayerEventSink();
            if (api != null) {
                eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        eventSink.event = events;
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        eventSink.event = null;
                    }
                });
                api.setNotificationStream(context, eventSink);
            } else {
                eventChannel.setStreamHandler(null);
            }
        }

        {
            EventChannel eventChannel = new EventChannel(binaryMessenger, "io.github.wangyng.simple_audio_player/becomingNoisyStream");
            SimpleAudioPlayerEventSink eventSink = new SimpleAudioPlayerEventSink();
            if (api != null) {
                eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        eventSink.event = events;
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        eventSink.event = null;
                    }
                });
                api.setBecomingNoisyStream(context, eventSink);
            } else {
                eventChannel.setStreamHandler(null);
            }
        }

        {
            BasicMessageChannel<Object> channel = new BasicMessageChannel<>(binaryMessenger, "io.github.wangyng.simple_audio_player.init", new StandardMessageCodec());
            if (api != null) {
                channel.setMessageHandler((message, reply) -> {
                    Map<String, Object> wrapped = new HashMap<>();
                    try {
                        HashMap<String, Object> params = (HashMap<String, Object>) message;
                        int playerId = (int)params.get("playerId");
                        api.init(context, playerId);
                        wrapped.put("result", null);
                    } catch (Exception exception) {
                        wrapped.put("error", wrapError(exception));
                    }
                    reply.reply(wrapped);
                });
            } else {
                channel.setMessageHandler(null);
            }
        }

        {
            BasicMessageChannel<Object> channel = new BasicMessageChannel<>(binaryMessenger, "io.github.wangyng.simple_audio_player.prepare", new StandardMessageCodec());
            if (api != null) {
                channel.setMessageHandler((message, reply) -> {
                    Map<String, Object> wrapped = new HashMap<>();
                    try {
                        HashMap<String, Object> params = (HashMap<String, Object>) message;
                        int playerId = (int)params.get("playerId");
                        String uri = (String)params.get("uri");
                        if (uri.startsWith("asset:///")) {
                            FlutterLoader loader = FlutterInjector.instance().flutterLoader();
                            String filename = loader.getLookupKeyForAsset(uri.substring("asset:///".length()));
                            uri = "asset:///" + filename;
                        }

                        api.prepare(context, playerId, uri);
                        wrapped.put("result", null);
                    } catch (Exception exception) {
                        wrapped.put("error", wrapError(exception));
                    }
                    reply.reply(wrapped);
                });
            } else {
                channel.setMessageHandler(null);
            }
        }

        {
            BasicMessageChannel<Object> channel = new BasicMessageChannel<>(binaryMessenger, "io.github.wangyng.simple_audio_player.play", new StandardMessageCodec());
            if (api != null) {
                channel.setMessageHandler((message, reply) -> {
                    Map<String, Object> wrapped = new HashMap<>();
                    try {
                        HashMap<String, Object> params = (HashMap<String, Object>) message;
                        int playerId = (int)params.get("playerId");
                        api.play(context, playerId);
                        wrapped.put("result", null);
                    } catch (Exception exception) {
                        wrapped.put("error", wrapError(exception));
                    }
                    reply.reply(wrapped);
                });
            } else {
                channel.setMessageHandler(null);
            }
        }

        {
            BasicMessageChannel<Object> channel = new BasicMessageChannel<>(binaryMessenger, "io.github.wangyng.simple_audio_player.pause", new StandardMessageCodec());
            if (api != null) {
                channel.setMessageHandler((message, reply) -> {
                    Map<String, Object> wrapped = new HashMap<>();
                    try {
                        HashMap<String, Object> params = (HashMap<String, Object>) message;
                        int playerId = (int)params.get("playerId");
                        api.pause(context, playerId);
                        wrapped.put("result", null);
                    } catch (Exception exception) {
                        wrapped.put("error", wrapError(exception));
                    }
                    reply.reply(wrapped);
                });
            } else {
                channel.setMessageHandler(null);
            }
        }

        {
            BasicMessageChannel<Object> channel = new BasicMessageChannel<>(binaryMessenger, "io.github.wangyng.simple_audio_player.stop", new StandardMessageCodec());
            if (api != null) {
                channel.setMessageHandler((message, reply) -> {
                    Map<String, Object> wrapped = new HashMap<>();
                    try {
                        HashMap<String, Object> params = (HashMap<String, Object>) message;
                        int playerId = (int)params.get("playerId");
                        api.stop(context, playerId);
                        wrapped.put("result", null);
                    } catch (Exception exception) {
                        wrapped.put("error", wrapError(exception));
                    }
                    reply.reply(wrapped);
                });
            } else {
                channel.setMessageHandler(null);
            }
        }

        {
            BasicMessageChannel<Object> channel = new BasicMessageChannel<>(binaryMessenger, "io.github.wangyng.simple_audio_player.seekTo", new StandardMessageCodec());
            if (api != null) {
                channel.setMessageHandler((message, reply) -> {
                    Map<String, Object> wrapped = new HashMap<>();
                    try {
                        HashMap<String, Object> params = (HashMap<String, Object>) message;
                        int playerId = (int) params.get("playerId");
                        Long position = (long) (int) params.get("position");
                        api.seekTo(context, playerId, position);
                        wrapped.put("result", null);
                    } catch (Exception exception) {
                        wrapped.put("error", wrapError(exception));
                    }
                    reply.reply(wrapped);
                });
            } else {
                channel.setMessageHandler(null);
            }
        }

        {
            BasicMessageChannel<Object> channel = new BasicMessageChannel<>(binaryMessenger, "io.github.wangyng.simple_audio_player.setVolume", new StandardMessageCodec());
            if (api != null) {
                channel.setMessageHandler((message, reply) -> {
                    Map<String, Object> wrapped = new HashMap<>();
                    try {
                        HashMap<String, Object> params = (HashMap<String, Object>) message;
                        int playerId = (int) params.get("playerId");
                        double volume = (double) params.get("volume");
                        api.setVolume(context, playerId, volume);
                        wrapped.put("result", null);
                    } catch (Exception exception) {
                        wrapped.put("error", wrapError(exception));
                    }
                    reply.reply(wrapped);
                });
            } else {
                channel.setMessageHandler(null);
            }
        }

        {
            BasicMessageChannel<Object> channel = new BasicMessageChannel<>(binaryMessenger, "io.github.wangyng.simple_audio_player.getCurrentPosition", new StandardMessageCodec());
            if (api != null) {
                channel.setMessageHandler((message, reply) -> {
                    Map<String, Object> wrapped = new HashMap<>();
                    try {
                        HashMap<String, Object> params = (HashMap<String, Object>) message;
                        int playerId = (int)params.get("playerId");
                        Long result = api.getCurrentPosition(context, playerId);
                        wrapped.put("result", result);
                    } catch (Exception exception) {
                        wrapped.put("error", wrapError(exception));
                    }
                    reply.reply(wrapped);
                });
            } else {
                channel.setMessageHandler(null);
            }
        }

        {
            BasicMessageChannel<Object> channel = new BasicMessageChannel<>(binaryMessenger, "io.github.wangyng.simple_audio_player.getDuration", new StandardMessageCodec());
            if (api != null) {
                channel.setMessageHandler((message, reply) -> {
                    Map<String, Object> wrapped = new HashMap<>();
                    try {
                        HashMap<String, Object> params = (HashMap<String, Object>) message;
                        int playerId = (int)params.get("playerId");
                        Long result = api.getDuration(context, playerId);
                        wrapped.put("result", result);
                    } catch (Exception exception) {
                        wrapped.put("error", wrapError(exception));
                    }
                    reply.reply(wrapped);
                });
            } else {
                channel.setMessageHandler(null);
            }
        }

        {
            BasicMessageChannel<Object> channel = new BasicMessageChannel<>(binaryMessenger, "io.github.wangyng.simple_audio_player.tryToGetAudioFocus", new StandardMessageCodec());
            if (api != null) {
                channel.setMessageHandler((message, reply) -> {
                    Map<String, Object> wrapped = new HashMap<>();
                    try {
                        boolean result = api.tryToGetAudioFocus(context);
                        wrapped.put("result", result);
                    } catch (Exception exception) {
                        wrapped.put("error", wrapError(exception));
                    }
                    reply.reply(wrapped);
                });
            } else {
                channel.setMessageHandler(null);
            }
        }

        {
            BasicMessageChannel<Object> channel = new BasicMessageChannel<>(binaryMessenger, "io.github.wangyng.simple_audio_player.giveUpAudioFocus", new StandardMessageCodec());
            if (api != null) {
                channel.setMessageHandler((message, reply) -> {
                    Map<String, Object> wrapped = new HashMap<>();
                    try {
                        api.giveUpAudioFocus(context);
                        wrapped.put("result", null);
                    } catch (Exception exception) {
                        wrapped.put("error", wrapError(exception));
                    }
                    reply.reply(wrapped);
                });
            } else {
                channel.setMessageHandler(null);
            }
        }

        {
            BasicMessageChannel<Object> channel = new BasicMessageChannel<>(binaryMessenger, "io.github.wangyng.simple_audio_player.showNotification", new StandardMessageCodec());
            if (api != null) {
                channel.setMessageHandler((message, reply) -> {
                    Map<String, Object> wrapped = new HashMap<>();
                    try {
                        HashMap<String, Object> params = (HashMap<String, Object>) message;
                        String title = (String)params.get("title");
                        String artist = (String)params.get("artist");
                        String clipArt = (String)params.get("clipArt");
                        api.showNotification(context, title, artist, clipArt);
                        wrapped.put("result", null);
                    } catch (Exception exception) {
                        wrapped.put("error", wrapError(exception));
                    }
                    reply.reply(wrapped);
                });
            } else {
                channel.setMessageHandler(null);
            }
        }

        {
            BasicMessageChannel<Object> channel = new BasicMessageChannel<>(binaryMessenger, "io.github.wangyng.simple_audio_player.updateNotification", new StandardMessageCodec());
            if (api != null) {
                channel.setMessageHandler((message, reply) -> {
                    Map<String, Object> wrapped = new HashMap<>();
                    try {
                        HashMap<String, Object> params = (HashMap<String, Object>) message;
                        boolean showPlay = (boolean)params.get("showPlay");
                        String title = (String)params.get("title");
                        String artist = (String)params.get("artist");
                        String clipArt = (String)params.get("clipArt");
                        api.updateNotification(context, showPlay, title, artist, clipArt);
                        wrapped.put("result", null);
                    } catch (Exception exception) {
                        wrapped.put("error", wrapError(exception));
                    }
                    reply.reply(wrapped);
                });
            } else {
                channel.setMessageHandler(null);
            }
        }

        {
            BasicMessageChannel<Object> channel = new BasicMessageChannel<>(binaryMessenger, "io.github.wangyng.simple_audio_player.cancelNotification", new StandardMessageCodec());
            if (api != null) {
                channel.setMessageHandler((message, reply) -> {
                    Map<String, Object> wrapped = new HashMap<>();
                    try {
                        api.cancelNotification(context);
                        wrapped.put("result", null);
                    } catch (Exception exception) {
                        wrapped.put("error", wrapError(exception));
                    }
                    reply.reply(wrapped);
                });
            } else {
                channel.setMessageHandler(null);
            }
        }

   }

    static HashMap<String, Object> wrapError(Exception exception) {
        HashMap<String, Object> errorMap = new HashMap<>();
        errorMap.put("message", exception.toString());
        errorMap.put("code", null);
        errorMap.put("details", null);
        return errorMap;
    }
}
