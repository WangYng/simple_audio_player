//
//  SimpleAudioFocusManager.h
//  simple_audio_player
//
//  Created by 汪洋 on 2021/8/6.
//

#import <Foundation/Foundation.h>

@protocol SimpleAudioFocusChangeDelegate <NSObject>
@required

- (void)onAudioFocused;
    
- (void)onAudioNoFocus;

- (void)onAudioBecomingNoisy;

@end

@interface SimpleAudioFocusManager : NSObject

@property (nonatomic, weak) id<SimpleAudioFocusChangeDelegate> delegate;

- (BOOL)tryToGetAudioFocus;

- (void) giveUpAudioFocus;

@end
