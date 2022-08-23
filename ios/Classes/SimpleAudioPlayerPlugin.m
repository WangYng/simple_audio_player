//
//  SimpleAudioPlayerPlugin.m
//  Pods
//
//  Created by 汪洋 on 2021/8/6.
//

#import "SimpleAudioPlayerPlugin.h"
#import "SimpleAudioPlayerEventSink.h"
#import "player/SimpleAudioPlayerManager.h"
#import "player/SimpleAudioFocusManager.h"
#import "player/SimpleAudioNotificationManager.h"

@interface SimpleAudioPlayerPlugin () <SimpleAudioFocusChangeDelegate, SimpleAudioNotificationDelegate>

@property(nonatomic, strong) NSMutableDictionary *playerManagerMap;
@property(nonatomic, strong) NSMutableDictionary *playerManagerDelegateMap;
@property(nonatomic, strong) SimpleAudioPlayerEventSink *songStateStream;

@property(nonatomic, strong) SimpleAudioFocusManager *audioFocusManager;
@property(nonatomic, strong) SimpleAudioPlayerEventSink *audioFocusStream;

@property(nonatomic, strong) SimpleAudioNotificationManager *notificationManager;
@property(nonatomic, strong) SimpleAudioPlayerEventSink *notificationStream;

@property(nonatomic, strong) SimpleAudioPlayerEventSink *becomingNoisyStream;

@end

@interface SimpleAudioPlayerStateImpl : NSObject<SimpleAudioPlayerStateDelegate>

@property(nonatomic, weak) SimpleAudioPlayerPlugin* plugin;

@property(nonatomic, assign) NSInteger playerId;

@end

@implementation SimpleAudioPlayerPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    SimpleAudioPlayerPlugin* instance = [[SimpleAudioPlayerPlugin alloc] init];
    [SimpleAudioPlayerApi setup:registrar api:instance];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _playerManagerMap = [[NSMutableDictionary alloc] init];
        _playerManagerDelegateMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)initWithPlayerId:(NSInteger)playerId {
    SimpleAudioPlayerManager *player = [[SimpleAudioPlayerManager alloc] init];
    SimpleAudioPlayerStateImpl *playerDelegate = [[SimpleAudioPlayerStateImpl alloc] init];
    playerDelegate.plugin = self;
    playerDelegate.playerId = playerId;
    player.delegate = playerDelegate;
    self.playerManagerMap[@(playerId)] = player;
    self.playerManagerDelegateMap[@(playerId)] = playerDelegate;
}

- (void)prepareWithPlayerId:(NSInteger)playerId uri:(NSString *)uri {
    SimpleAudioPlayerManager *player = self.playerManagerMap[@(playerId)];
    NSURL *url;
    if ([uri hasPrefix:@"http"]) {
        url = [[NSURL alloc] initWithString:uri];
    } else if ([uri hasPrefix:@"file://"]){
        url = [[NSURL alloc] initFileURLWithPath:[uri substringFromIndex:@"file://".length]];
    }
    [player prepareWithUrl:url];
}

- (void)playWithPlayerId:(NSInteger)playerId {
    SimpleAudioPlayerManager *player = self.playerManagerMap[@(playerId)];
    [player play];
}

- (void)pauseWithPlayerId:(NSInteger)playerId {
    SimpleAudioPlayerManager *player = self.playerManagerMap[@(playerId)];
    [player pause];
}

- (void)stopWithPlayerId:(NSInteger)playerId {
    SimpleAudioPlayerManager *player = self.playerManagerMap[@(playerId)];
    [player stop];
}

- (void)seekToWithPlayerId:(NSInteger)playerId position:(NSInteger)position {
    SimpleAudioPlayerManager *player = self.playerManagerMap[@(playerId)];
    [player seekToWithPosition:position];
}

- (void)setVolumeWithPlayerId:(NSInteger)playerId volume:(double)volume {
    SimpleAudioPlayerManager *player = self.playerManagerMap[@(playerId)];
    [player setVolume:volume];
}

- (NSInteger)getCurrentPositionWithPlayerId:(NSInteger)playerId {
    SimpleAudioPlayerManager *player = self.playerManagerMap[@(playerId)];
    return player.currentPosition;
}

- (NSInteger)getDurationWithPlayerId:(NSInteger)playerId {
    SimpleAudioPlayerManager *player = self.playerManagerMap[@(playerId)];
    return player.duration;
}

- (void)giveUpAudioFocus {
    [self.audioFocusManager giveUpAudioFocus];
}

- (BOOL)tryToGetAudioFocus {
    if (self.audioFocusManager == nil) {
        self.audioFocusManager = [[SimpleAudioFocusManager alloc] init];
    }
    self.audioFocusManager.delegate = self;
    return [self.audioFocusManager tryToGetAudioFocus];
}

- (void)onAudioFocused {
    if (self.audioFocusStream.event) {
        self.audioFocusStream.event(@"audioFocused");
    }
}

- (void)onAudioNoFocus {
    if (self.audioFocusStream.event) {
        self.audioFocusStream.event(@"audioNoFocus");
    }
}

- (void)onAudioBecomingNoisy {
    if (self.becomingNoisyStream.event) {
        self.becomingNoisyStream.event(@"becomingNoisy");
    }
}

- (void)showNotificationWithTitle:(NSString *)title artist:(NSString *)artist clipArt:(NSString *)clipArt {
    if (self.notificationManager == nil) {
        self.notificationManager = [[SimpleAudioNotificationManager alloc] init];
        self.notificationManager.delegate = self;
    }
    SimpleAudioPlayerSong *song = [[SimpleAudioPlayerSong alloc] initWithTitle:title artist:artist clipArt:clipArt];
    [self.notificationManager showNotificationWithSong:song];
}

- (void)updateNotificationWithShowPlay:(BOOL)showPlay title:(NSString *)title artist:(NSString *)artist clipArt:(NSString *)clipArt {
    SimpleAudioPlayerSong *song = [[SimpleAudioPlayerSong alloc] initWithTitle:title artist:artist clipArt:clipArt];
    [self.notificationManager updateNotificationWithShowPlay:showPlay song:song];
}

- (void)cancelNotification {
    [self.notificationManager cancelNotification];
}

- (void)onReceivePause {
    if (self.notificationStream.event) {
        self.notificationStream.event(@"onPause");
    }
}

- (void)onReceivePlay {
    if (self.notificationStream.event) {
        self.notificationStream.event(@"onPlay");
    }
}

- (void)onReceiveSkipToNext {
    if (self.notificationStream.event) {
        self.notificationStream.event(@"onSkipToNext");
    }
}

- (void)onReceiveSkipToPrevious {
    if (self.notificationStream.event) {
        self.notificationStream.event(@"onSkipToPrevious");
    }
}

- (void)onReceiveStop {
    if (self.notificationStream.event) {
        self.notificationStream.event(@"onStop");
    }
}

@end

@implementation SimpleAudioPlayerStateImpl

- (void)onReadyWithDuration:(NSInteger)duration; {
    if (self.plugin.songStateStream.event) {
        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
        result[@"playerId"] = @(self.playerId);
        result[@"event"] = @"onReady";
        result[@"data"] = @(duration);
        self.plugin.songStateStream.event(result);
    }
}

- (void)onPlayEnd {
    if (self.plugin.songStateStream.event) {
        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
        result[@"playerId"] = @(self.playerId);
        result[@"event"] = @"onPlayEnd";
        self.plugin.songStateStream.event(result);
    }
}


- (void)onErrorWithMessage:(NSString *)message {
    if (self.plugin.songStateStream.event) {
        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
        result[@"playerId"] = @(self.playerId);
        result[@"event"] = @"onError";
        result[@"data"] = message;
        self.plugin.songStateStream.event(result);
    }
}

- (void)onPositionChangeWithPosition:(NSInteger)position duration:(NSInteger)duration {
    if (self.plugin.songStateStream.event) {
        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
        result[@"playerId"] = @(self.playerId);
        result[@"event"] = @"onPositionChange";
        result[@"data"] = @[@(position), @(duration)];
        self.plugin.songStateStream.event(result);
    }
}


@end
