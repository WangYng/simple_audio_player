//
//  SimpleAudioPlayerApi.h
//  Pods
//
//  Created by 汪洋 on 2021/8/16.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "SimpleAudioPlayerEventSink.h"

@protocol SimpleAudioPlayerApiDelegate <NSObject>

- (void)setSongStateStream:(SimpleAudioPlayerEventSink *)songStateStream;

- (void)setAudioFocusStream:(SimpleAudioPlayerEventSink *)audioFocusStream;

- (void)setNotificationStream:(SimpleAudioPlayerEventSink *)notificationStream;

- (void)setBecomingNoisyStream:(SimpleAudioPlayerEventSink *)becomingNoisyStream;

- (void)initWithPlayerId:(NSInteger)playerId;

- (void)prepareWithPlayerId:(NSInteger)playerId uri:(NSString *)uri;

- (void)playWithPlayerId:(NSInteger)playerId;

- (void)pauseWithPlayerId:(NSInteger)playerId;

- (void)stopWithPlayerId:(NSInteger)playerId;

- (void)seekToWithPlayerId:(NSInteger)playerId position:(NSInteger)position;

- (void)setVolumeWithPlayerId:(NSInteger)playerId volume:(double)volume;

- (NSInteger)getCurrentPositionWithPlayerId:(NSInteger)playerId;

- (NSInteger)getDurationWithPlayerId:(NSInteger)playerId;

- (BOOL)tryToGetAudioFocus;

- (void)giveUpAudioFocus;

- (void)showNotificationWithTitle:(NSString *)title artist:(NSString *)artist clipArt:(NSString *)clipArt;

- (void)updateNotificationWithShowPlay:(BOOL)showPlay title:(NSString *)title artist:(NSString *)artist clipArt:(NSString *)clipArt;

- (void)cancelNotification;

@end

@interface SimpleAudioPlayerApi : NSObject

+ (void)setup:(NSObject<FlutterPluginRegistrar> *)registrar api:(id<SimpleAudioPlayerApiDelegate>)api;

@end

