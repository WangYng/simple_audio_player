//
//  SimpleAudioNotificationManager.m
//  simple_audio_player
//
//  Created by 汪洋 on 2021/8/13.
//

#import "SimpleAudioNotificationManager.h"
#import <MediaPlayer/MediaPlayer.h>

@interface SimpleAudioNotificationManager ()

@property (nonatomic, strong) MPRemoteCommandCenter *remoteCommandCenter;

@property (nonatomic, strong) MPNowPlayingInfoCenter *playingCenter;

@property (nonatomic, strong) SimpleAudioPlayerManager *player;

@property (nonatomic, strong) SimpleAudioPlayerSong *song;

@end

@interface SimpleAudioNotificationManager (Helper)

- (void)updateNotification;

- (MPRemoteCommandHandlerStatus)skipToNextEvent:(MPRemoteCommandEvent *)event;

- (MPRemoteCommandHandlerStatus)skipToPreviousEvent:(MPRemoteCommandEvent *)event;

- (MPRemoteCommandHandlerStatus)playEvent:(MPRemoteCommandEvent *)event;

- (MPRemoteCommandHandlerStatus)pauseEvent:(MPRemoteCommandEvent *)event;

- (MPRemoteCommandHandlerStatus)stopEvent:(MPRemoteCommandEvent *)event;

@end

@implementation SimpleAudioNotificationManager

- (void)showNotificationWithPlayer:(SimpleAudioPlayerManager *) player song:(SimpleAudioPlayerSong *)song {
    [UIApplication.sharedApplication beginReceivingRemoteControlEvents];

    if (self.playingCenter == nil) {
        self.playingCenter = [MPNowPlayingInfoCenter defaultCenter];
    }
    if (self.remoteCommandCenter == nil) {
        self.remoteCommandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    }
    
    self.player = player;
    self.song = song;
    
    [self updateNotification];
}

- (void)updateNotificationWithPlayer:(SimpleAudioPlayerManager *) player  song:(SimpleAudioPlayerSong *)song {
    self.player = player;
    self.song = song;
    
    [self updateNotification];
}

- (void)cancelNotification {
    if (self.playingCenter != nil) {
        [self.playingCenter setNowPlayingInfo:@{}];
    }
    if (self.remoteCommandCenter != nil) {
        {
            MPRemoteCommand *command = self.remoteCommandCenter.nextTrackCommand;
            [command removeTarget:self action:@selector(skipToNextEvent:)];
        }
        {
            MPRemoteCommand *command = self.remoteCommandCenter.previousTrackCommand;
            [command removeTarget:self action:@selector(skipToPreviousEvent:)];
        }
        {
            MPRemoteCommand *command = self.remoteCommandCenter.playCommand;
            [command removeTarget:self action:@selector(playEvent:)];
        }
        {
            MPRemoteCommand *command = self.remoteCommandCenter.pauseCommand;
            [command removeTarget:self action:@selector(pauseEvent:)];
        }
        {
            MPRemoteCommand *command = self.remoteCommandCenter.stopCommand;
            [command removeTarget:self action:@selector(stopEvent:)];
        }
    }

    self.playingCenter = nil;
    self.remoteCommandCenter = nil;
    
    self.player = nil;
    self.song = nil;
    
    [UIApplication.sharedApplication endReceivingRemoteControlEvents];
}

@end

@implementation SimpleAudioNotificationManager (Helper)

- (void)updateNotification {
    {
        MPRemoteCommand *command = self.remoteCommandCenter.nextTrackCommand;
        [command setEnabled:YES];
        [command addTarget:self action:@selector(skipToNextEvent:)];
    }
    {
        MPRemoteCommand *command = self.remoteCommandCenter.previousTrackCommand;
        [command setEnabled:YES];
        [command addTarget:self action:@selector(skipToPreviousEvent:)];
    }
    {
        MPRemoteCommand *command = self.remoteCommandCenter.playCommand;
        [command setEnabled:YES];
        [command addTarget:self action:@selector(playEvent:)];
    }
    {
        MPRemoteCommand *command = self.remoteCommandCenter.pauseCommand;
        [command setEnabled:YES];
        [command addTarget:self action:@selector(pauseEvent:)];
    }
    {
        MPRemoteCommand *command = self.remoteCommandCenter.stopCommand;
        [command setEnabled:YES];
        [command addTarget:self action:@selector(stopEvent:)];
    }
    
    NSMutableDictionary<NSString *,id> *playingInfo = [@{
        MPMediaItemPropertyTitle: self.song.title,
        MPMediaItemPropertyArtist: self.song.artist,
        MPMediaItemPropertyPlaybackDuration: @(self.player.duration / 1000),
        MPNowPlayingInfoPropertyPlaybackRate: @(self.player.playbackRate),
        MPNowPlayingInfoPropertyElapsedPlaybackTime: @(self.player.currentPosition / 1000),
    } mutableCopy];
    
    if (self.song.clipArt != nil && self.song.clipArt.length > 0 ) {
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:self.song.clipArt options:0];
        UIImage *clipArtImage = [[UIImage alloc] initWithData:decodedData];
        playingInfo[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithImage:clipArtImage];
    }
    
    [self.playingCenter setNowPlayingInfo:playingInfo];
}

- (MPRemoteCommandHandlerStatus)skipToNextEvent:(MPRemoteCommandEvent *)event {
    if (self.delegate != nil) {
        [self.delegate onReceiveSkipToNext];
    }
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)skipToPreviousEvent:(MPRemoteCommandEvent *)event {
    if (self.delegate != nil) {
        [self.delegate onReceiveSkipToPrevious];
    }
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)playEvent:(MPRemoteCommandEvent *)event {
    if (self.delegate != nil) {
        [self.delegate onReceivePlay];
    }
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)pauseEvent:(MPRemoteCommandEvent *)event {
    if (self.delegate != nil) {
        [self.delegate onReceivePause];
    }
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)stopEvent:(MPRemoteCommandEvent *)event {
    if (self.delegate != nil) {
        [self.delegate onReceiveStop];
    }
    return MPRemoteCommandHandlerStatusSuccess;
}

@end
