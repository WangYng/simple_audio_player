//
//  SimpleAudioPlayerSong.m
//  simple_audio_player
//
//  Created by 汪洋 on 2021/8/6.
//

#import "SimpleAudioPlayerSong.h"

@implementation SimpleAudioPlayerSong

- (instancetype)initWithTitle:(NSString *)title artist:(NSString *)artist clipArt:(NSString *)clipArt {
    self = [super init];
    if (self) {
        _title = title;
        _artist = artist;
        _clipArt = clipArt;
    }
    return self;
}

@end
