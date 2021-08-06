//
//  SimpleAudioPlayerApi.h
//  Pods
//
//  Created by 汪洋 on 2021/8/6.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "SimpleAudioPlayerEventSink.h"

@protocol SimpleAudioPlayerApiDelegate <NSObject>

- (void)setSongStateStream:(SimpleAudioPlayerEventSink *)songStateStream;

- (void)initWithPlayerId:(NSInteger)playerId;

- (void)prepareWithPlayerId:(NSInteger)playerId uri:(NSString *)uri;

- (void)playWithPlayerId:(NSInteger)playerId;

- (void)pauseWithPlayerId:(NSInteger)playerId;

- (void)stopWithPlayerId:(NSInteger)playerId;

- (void)seekToWithPlayerId:(NSInteger)playerId position:(NSInteger)position;

- (NSInteger)getCurrentPositionWithPlayerId:(NSInteger)playerId;

- (NSInteger)getDurationWithPlayerId:(NSInteger)playerId;

@end

@interface SimpleAudioPlayerApi : NSObject

+ (void)setup:(NSObject<FlutterBinaryMessenger> *)messenger api:(id<SimpleAudioPlayerApiDelegate>)api;

@end

