//
//  SimpleAudioPlayerSong.h
//  simple_audio_player
//
//  Created by 汪洋 on 2021/8/6.
//

#import <Foundation/Foundation.h>

@interface SimpleAudioPlayerSong : NSObject

@property(nonatomic, strong)NSURL *source;

- (instancetype)initWithSource:(NSURL *)source;

@end
