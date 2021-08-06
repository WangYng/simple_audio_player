//
//  SimpleAudioPlayerPlugin.h
//  Pods
//
//  Created by 汪洋 on 2021/8/6.
//

#import <Flutter/Flutter.h>
#import "SimpleAudioPlayerApi.h"

@interface SimpleAudioPlayerPlugin : NSObject<SimpleAudioPlayerApiDelegate>

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;

@end
