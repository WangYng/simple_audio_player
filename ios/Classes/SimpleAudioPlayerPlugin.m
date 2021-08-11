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

@interface SimpleAudioPlayerPlugin () <SimpleAudioFocusChangeDelegate>

@property(nonatomic, strong) NSMutableDictionary *playerManagerMap;
@property(nonatomic, strong) NSMutableDictionary *playerManagerDelegateMap;

@property(nonatomic, strong) SimpleAudioPlayerEventSink *songStateStream;

@property(nonatomic, strong) SimpleAudioFocusManager *audioFocusManager;
@property(nonatomic, strong) SimpleAudioPlayerEventSink *audioFocusStream;

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

- (void)setSongStateStream:(SimpleAudioPlayerEventSink *)songStateStream {
    _songStateStream = songStateStream;
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
    SimpleAudioPlayerSong *song = [[SimpleAudioPlayerSong alloc] initWithSource:url];
    [player prepareWithSong:song];
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
    self.audioFocusStream.event(@"audioFocused");
}

- (void)onAudioNoFocus {
    self.audioFocusStream.event(@"audioNoFocus");
}

@end

@implementation SimpleAudioPlayerStateImpl

- (void)onReady {
    if (self.plugin.songStateStream.event) {
        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
        result[@"playerId"] = @(self.playerId);
        result[@"event"] = @"onReady";
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
