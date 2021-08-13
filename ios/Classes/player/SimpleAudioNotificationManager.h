//
//  SimpleAudioNotificationManager.h
//  simple_audio_player
//
//  Created by 汪洋 on 2021/8/13.
//

#import <Foundation/Foundation.h>
#import "SimpleAudioPlayerSong.h"

@protocol SimpleAudioNotificationDelegate <NSObject>

- (void)onReceivePlay;

- (void)onReceivePause;

- (void)onReceiveSkipToNext;

- (void)onReceiveSkipToPrevious;

- (void)onReceiveStop;

@end

@interface SimpleAudioNotificationManager : NSObject

@property(nonatomic, weak) id<SimpleAudioNotificationDelegate> delegate;

- (void)showNotificationWithSong:(SimpleAudioPlayerSong *)song;

- (void)updateNotificationWithShowPlay:(BOOL)showPlay song:(SimpleAudioPlayerSong *)song;

- (void)cancelNotification;

@end
