//
//  SimpleAudioPlayerEventSink.h
//  Pods
//
//  Created by 汪洋 on 2021/8/6.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@interface SimpleAudioPlayerEventSink : NSObject <FlutterStreamHandler>

@property (nonatomic, copy) FlutterEventSink event;

@end
