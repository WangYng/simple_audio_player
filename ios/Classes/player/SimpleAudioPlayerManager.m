//
//  SimpleAudioPlayerManager.m
//  simple_audio_player
//
//  Created by 汪洋 on 2021/8/6.
//

#import "SimpleAudioPlayerManager.h"
#import <AVKit/AVKit.h>

@interface SimpleAudioPlayerManager ()

@property(nonatomic, strong) AVPlayer *player;

@property(nonatomic, strong) AVPlayerItem *playerItem;

@property(nonatomic, strong) NSURL *currentUrl;

@property(nonatomic, assign) BOOL playWhenReady;

@property(nonatomic, strong) id timeObserverToken;

@property(nonatomic, strong) id playToEndObserverToken;

@property(nonatomic, assign) double rate;

@end

@interface SimpleAudioPlayerManager (Listener)

- (void)addPlayerListenerWithPlayerItem:(AVPlayerItem *)playerItem;

- (void)removePlayerListener;

@end

@interface AVPlayer (Extension)

@property (nonatomic, assign, readonly) BOOL isPlaying;

@end

@implementation SimpleAudioPlayerManager

- (void)prepareWithUrl:(NSURL *)url {
    BOOL songHasChanged = self.currentUrl == nil || url != self.currentUrl;
    if (songHasChanged) {
        self.currentUrl = url;
    }
    
    if (songHasChanged || self.player == nil) {
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
        
        if (self.player == nil) {
            self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        } else {
            [self removePlayerListener];
            [self.player replaceCurrentItemWithPlayerItem:playerItem];
        }
        [self addPlayerListenerWithPlayerItem:playerItem];
    }
}

- (void)play {
    [self.player play];
    if (self.rate != 0 && self.player.rate != self.rate) {
        self.player.rate = self.rate;
    }
}

- (void)pause {
    [self.player pause];
}

- (void)stop {
    [self pause];
    [self removePlayerListener];
    self.player = nil;
}

- (void)seekToWithPosition:(NSInteger)position {
    if (self.player != nil && self.player.currentItem != nil) {
        [self.player.currentItem seekToTime:CMTimeMake(position, 1000) completionHandler:nil];
    }
}

- (NSInteger)currentPosition {
    if (self.player == nil) {
        return 0;
    } else {
        Float64 seconds = CMTimeGetSeconds(self.player.currentTime);
        return (NSInteger)(seconds * 1000);
    }
}

- (NSInteger)duration {
    if (self.player == nil && self.player.currentItem == nil) {
        return 0;
    } else {
        Float64 seconds = CMTimeGetSeconds(self.player.currentItem.asset.duration);
        return (NSInteger)(seconds * 1000);
    }
}

- (void)setVolume:(double)volume {
    if (self.player == nil) {
        return;
    } else {
        self.player.volume = volume;
    }
}

- (void)setPlaybackRateWithRate:(double)playbackRate {
    if (self.player == nil) {
        return;
    } else {
        self.rate = playbackRate;
        if (self.player.isPlaying) {
            self.player.rate = self.rate;
        }
    }
}

@end


@implementation SimpleAudioPlayerManager (Listener)

- (void)addPlayerListenerWithPlayerItem:(AVPlayerItem *)playerItem {
    __weak typeof(self) ws = self;
    self.timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC) queue:nil usingBlock:^(CMTime time) {
            if (ws.player.isPlaying) {
                [ws updateProgressWithTime:time];
            }
    }];
    
    self.playToEndObserverToken = [NSNotificationCenter.defaultCenter addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:playerItem queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [ws onPlayEnd];
    }];
    
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[AVPlayerItem class]] && [keyPath isEqualToString:@"status"] ) {
        if ([change[NSKeyValueChangeNewKey] integerValue] == AVPlayerStatusReadyToPlay) {
            [self onReady];
        }else if ([change[NSKeyValueChangeNewKey] integerValue] == AVPlayerStatusFailed) {
            [self onErrorWithMessage: ((AVPlayerItem *)object).error.localizedDescription];
        }
    }
}

- (void)removePlayerListener {
    if (self.timeObserverToken) {
        [self.player removeTimeObserver:self.timeObserverToken];
    }
    if (self.playToEndObserverToken) {
        [NSNotificationCenter.defaultCenter removeObserver:self.playToEndObserverToken];
    }
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
    }
}

- (void)updateProgressWithTime:(CMTime)time {
    [self.delegate onPositionChangeWithPosition:(NSInteger)(CMTimeGetSeconds(time) * 1000) duration:self.duration];
}

- (void)onReady {
    [self.delegate onReadyWithDuration:self.duration];
}

- (void)onErrorWithMessage:(NSString *)message {
    [self.delegate onErrorWithMessage:message];
}

- (void)onPlayEnd {
    [self.delegate onPlayEnd];
}

@end

@implementation AVPlayer (Extension)

- (BOOL)isPlaying {
    return self.rate != 0 && self.error == nil;
}

@end
