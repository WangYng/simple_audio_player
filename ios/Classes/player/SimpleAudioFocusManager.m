//
//  SimpleAudioFocusManager.m
//  simple_audio_player
//
//  Created by 汪洋 on 2021/8/6.
//

#import "SimpleAudioFocusManager.h"
#import <AVKit/AVKit.h>

@interface SimpleAudioFocusManager ()

@property (nonatomic, strong) id interruptionObserverToken;

@end

@implementation SimpleAudioFocusManager

- (BOOL)tryToGetAudioFocus {
    NSError *error;
    [AVAudioSession.sharedInstance setActive:YES error:&error];
    [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    if (error != nil) {
        return NO;
    }
    
    if (self.delegate) {
        [self observeAudioFocusChange];
    }
    return YES;
}

- (void)observeAudioFocusChange {
    __weak typeof(self) ws = self;
    self.interruptionObserverToken = [NSNotificationCenter.defaultCenter addObserverForName:AVAudioSessionInterruptionNotification object:AVAudioSession.sharedInstance queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        if (note && note.userInfo) {
            AudioSessionInterruptionType type = [note.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
            AVAudioSessionInterruptionOptions options = [note.userInfo[AVAudioSessionInterruptionOptionKey] integerValue];
            
            if (type == AVAudioSessionInterruptionTypeBegan) {
                [ws.delegate onAudioNoFocus];
                
            } else if (type == AVAudioSessionInterruptionTypeEnded) {
                if (options & AVAudioSessionInterruptionOptionShouldResume) {
                    [ws.delegate onAudioFocused];
                }
            }
            
        }
    }];
}

- (void) giveUpAudioFocus {
    [AVAudioSession.sharedInstance setActive:false error:nil];
    if (self.interruptionObserverToken) {
        [NSNotificationCenter.defaultCenter removeObserver:self.interruptionObserverToken];
        self.interruptionObserverToken = nil;
    }
}

@end
