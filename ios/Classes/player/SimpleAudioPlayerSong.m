//
//  SimpleAudioPlayerSong.m
//  simple_audio_player
//
//  Created by 汪洋 on 2021/8/6.
//

#import "SimpleAudioPlayerSong.h"

@implementation SimpleAudioPlayerSong

- (instancetype)initWithSource:(NSURL *)source {

    self = [super init];
    if (self) {
        _source = source;
    }
    return self;
}

@end
