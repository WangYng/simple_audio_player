//
//  SimpleAudioNotificationManager.h
//  simple_audio_player
//
//  Created by 汪洋 on 2021/8/13.
//

#import <Foundation/Foundation.h>
#import "SimpleAudioPlayerSong.h"
#import "SimpleAudioPlayerManager.h"

@protocol SimpleAudioNotificationDelegate <NSObject>
@required

- (void)onReceivePlay;

- (void)onReceivePause;

- (void)onReceiveSkipToNext;

- (void)onReceiveSkipToPrevious;

- (void)onReceiveStop;

@end

@interface SimpleAudioNotificationManager : NSObject

@property(nonatomic, weak) id<SimpleAudioNotificationDelegate> delegate;

- (void)showNotificationWithPlayer:(SimpleAudioPlayerManager *) player  song:(SimpleAudioPlayerSong *)song;

- (void)updateNotificationWithPlayer:(SimpleAudioPlayerManager *) player  song:(SimpleAudioPlayerSong *)song;

- (void)cancelNotification;

@end
