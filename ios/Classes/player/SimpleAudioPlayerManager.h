//
//  SimpleAudioPlayerManager.h
//  simple_audio_player
//
//  Created by 汪洋 on 2021/8/6.
//

#import <Foundation/Foundation.h>

@protocol SimpleAudioPlayerStateDelegate <NSObject>
@required

- (void)onReadyWithDuration:(NSInteger)duration;

- (void)onPlayEnd;

- (void)onErrorWithMessage:(NSString *)message;

- (void)onPositionChangeWithPosition:(NSInteger)position duration:(NSInteger)duration;

@end


@interface SimpleAudioPlayerManager : NSObject

@property (nonatomic, weak) id<SimpleAudioPlayerStateDelegate> delegate;

@property (nonatomic, assign, readonly) NSInteger currentPosition;

@property (nonatomic, assign, readonly) NSInteger duration;

- (void)prepareWithUrl:(NSURL *)url;

- (void)play;

- (void)pause;

- (void)stop;

- (void)seekToWithPosition:(NSInteger)position;

- (void)setVolume:(double)volume;

- (void)setPlaybackRateWithRate:(double)playbackRate;

@end

