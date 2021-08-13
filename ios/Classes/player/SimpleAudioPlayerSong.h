//
//  SimpleAudioPlayerSong.h
//  simple_audio_player
//
//  Created by 汪洋 on 2021/8/6.
//

#import <Foundation/Foundation.h>

@interface SimpleAudioPlayerSong : NSObject

@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *artist;
@property(nonatomic, strong) NSString *clipArt;

- (instancetype)initWithTitle:(NSString *)title artist:(NSString *)artist clipArt:(NSString *)clipArt;

@end
