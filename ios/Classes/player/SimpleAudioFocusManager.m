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

@property (nonatomic, strong) id routeChangeObserverToken;

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
        [self observeAudioRouteChange];
    }
    return YES;
}

- (void)observeAudioFocusChange {
    __weak typeof(self) ws = self;
    if (self.interruptionObserverToken) {
        [NSNotificationCenter.defaultCenter removeObserver:self.interruptionObserverToken];
    }
    self.interruptionObserverToken = [NSNotificationCenter.defaultCenter addObserverForName:AVAudioSessionInterruptionNotification object:AVAudioSession.sharedInstance queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        if (note && note.userInfo) {
            AudioSessionInterruptionType type = [note.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
            
            if (type == AVAudioSessionInterruptionTypeBegan) {
                [ws.delegate onAudioNoFocus];
                
            } else if (type == AVAudioSessionInterruptionTypeEnded) {
                AVAudioSessionInterruptionOptions options = [note.userInfo[AVAudioSessionInterruptionOptionKey] integerValue];
                if (options & AVAudioSessionInterruptionOptionShouldResume) {
                    [ws.delegate onAudioFocused];
                    [ws tryToGetAudioFocus];
                }
            }
        }
    }];
}

- (void)observeAudioRouteChange {
    __weak typeof(self) ws = self;
    if (self.routeChangeObserverToken) {
        [NSNotificationCenter.defaultCenter removeObserver:self.routeChangeObserverToken];
    }
    self.routeChangeObserverToken = [NSNotificationCenter.defaultCenter addObserverForName:AVAudioSessionRouteChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        if (note && note.userInfo) {
            NSInteger routeChangeReason = [[note.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
            if (routeChangeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
                [ws.delegate onAudioBecomingNoisy];
            }
        }
    }];
}

- (void) giveUpAudioFocus {
    if (self.interruptionObserverToken) {
        [NSNotificationCenter.defaultCenter removeObserver:self.interruptionObserverToken];
        self.interruptionObserverToken = nil;
    }
    if (self.routeChangeObserverToken) {
        [NSNotificationCenter.defaultCenter removeObserver:self.routeChangeObserverToken];
        self.routeChangeObserverToken = nil;
    }
}

-(void)dealloc {
    [self giveUpAudioFocus];
}

@end
