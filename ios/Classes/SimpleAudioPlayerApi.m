//
//  SimpleAudioPlayerApi.m
//  Pods
//
//  Created by 汪洋 on 2021/8/13.
//

#import "SimpleAudioPlayerApi.h"

@implementation SimpleAudioPlayerApi

+ (void)setup:(NSObject<FlutterPluginRegistrar> *)registrar api:(id<SimpleAudioPlayerApiDelegate>)api {
    NSObject<FlutterBinaryMessenger> *messenger = [registrar messenger];
    
    {
        FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"io.github.wangyng.simple_audio_player/songStateStream" binaryMessenger:messenger];
        SimpleAudioPlayerEventSink *eventSink = [[SimpleAudioPlayerEventSink alloc] init];
        if (api != nil) {
            [eventChannel setStreamHandler:eventSink];
            [api setSongStateStream:eventSink];
        }
    }
    
    {
        FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"io.github.wangyng.simple_audio_player/audioFocusStream" binaryMessenger:messenger];
        SimpleAudioPlayerEventSink *eventSink = [[SimpleAudioPlayerEventSink alloc] init];
        if (api != nil) {
            [eventChannel setStreamHandler:eventSink];
            [api setAudioFocusStream:eventSink];
        }
    }

    {
        FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"io.github.wangyng.simple_audio_player/notificationStream" binaryMessenger:messenger];
        SimpleAudioPlayerEventSink *eventSink = [[SimpleAudioPlayerEventSink alloc] init];
        if (api != nil) {
            [eventChannel setStreamHandler:eventSink];
            [api setNotificationStream:eventSink];
        }
    }

    {
        FlutterBasicMessageChannel *channel =[FlutterBasicMessageChannel messageChannelWithName:@"io.github.wangyng.simple_audio_player.init" binaryMessenger:messenger];
        if (api != nil) {
            [channel setMessageHandler:^(id  message, FlutterReply reply) {
                NSMutableDictionary<NSString *, NSObject *> *wrapped = [NSMutableDictionary new];
                if ([message isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *params = message;
                    NSInteger playerId = [params[@"playerId"] integerValue];
                    [api initWithPlayerId:playerId];
                    wrapped[@"result"] = nil;
                } else {
                    wrapped[@"error"] = @{@"message": @"parse message error"};
                }
                reply(wrapped);
            }];
        } else {
            [channel setMessageHandler:nil];
        }
    }
    
    {
        FlutterBasicMessageChannel *channel =[FlutterBasicMessageChannel messageChannelWithName:@"io.github.wangyng.simple_audio_player.prepare" binaryMessenger:messenger];
        if (api != nil) {
            [channel setMessageHandler:^(id  message, FlutterReply reply) {
                NSMutableDictionary<NSString *, NSObject *> *wrapped = [NSMutableDictionary new];
                if ([message isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *params = message;
                    NSInteger playerId = [params[@"playerId"] integerValue];
                    NSString *uri = params[@"uri"];
                    if ([uri hasPrefix:@"asset:///"]) {
                        NSString* key = [registrar lookupKeyForAsset:[uri substringFromIndex:@"asset:///".length]];
                        NSString* path = [[NSBundle mainBundle] pathForResource:key ofType:nil];
                        uri = [NSString stringWithFormat:@"file://%@", path];
                    }
                    [api prepareWithPlayerId:playerId uri:uri];
                    wrapped[@"result"] = nil;
                } else {
                    wrapped[@"error"] = @{@"message": @"parse message error"};
                }
                reply(wrapped);
            }];
        } else {
            [channel setMessageHandler:nil];
        }
    }
    
    {
        FlutterBasicMessageChannel *channel =[FlutterBasicMessageChannel messageChannelWithName:@"io.github.wangyng.simple_audio_player.play" binaryMessenger:messenger];
        if (api != nil) {
            [channel setMessageHandler:^(id  message, FlutterReply reply) {
                NSMutableDictionary<NSString *, NSObject *> *wrapped = [NSMutableDictionary new];
                if ([message isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *params = message;
                    NSInteger playerId = [params[@"playerId"] integerValue];
                    [api playWithPlayerId:playerId];
                    wrapped[@"result"] = nil;
                } else {
                    wrapped[@"error"] = @{@"message": @"parse message error"};
                }
                reply(wrapped);
            }];
        } else {
            [channel setMessageHandler:nil];
        }
    }
    
    {
        FlutterBasicMessageChannel *channel =[FlutterBasicMessageChannel messageChannelWithName:@"io.github.wangyng.simple_audio_player.pause" binaryMessenger:messenger];
        if (api != nil) {
            [channel setMessageHandler:^(id  message, FlutterReply reply) {
                NSMutableDictionary<NSString *, NSObject *> *wrapped = [NSMutableDictionary new];
                if ([message isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *params = message;
                    NSInteger playerId = [params[@"playerId"] integerValue];
                    [api pauseWithPlayerId:playerId];
                    wrapped[@"result"] = nil;
                } else {
                    wrapped[@"error"] = @{@"message": @"parse message error"};
                }
                reply(wrapped);
            }];
        } else {
            [channel setMessageHandler:nil];
        }
    }
    
    {
        FlutterBasicMessageChannel *channel =[FlutterBasicMessageChannel messageChannelWithName:@"io.github.wangyng.simple_audio_player.stop" binaryMessenger:messenger];
        if (api != nil) {
            [channel setMessageHandler:^(id  message, FlutterReply reply) {
                NSMutableDictionary<NSString *, NSObject *> *wrapped = [NSMutableDictionary new];
                if ([message isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *params = message;
                    NSInteger playerId = [params[@"playerId"] integerValue];
                    [api stopWithPlayerId:playerId];
                    wrapped[@"result"] = nil;
                } else {
                    wrapped[@"error"] = @{@"message": @"parse message error"};
                }
                reply(wrapped);
            }];
        } else {
            [channel setMessageHandler:nil];
        }
    }
    
    {
        FlutterBasicMessageChannel *channel =[FlutterBasicMessageChannel messageChannelWithName:@"io.github.wangyng.simple_audio_player.seekTo" binaryMessenger:messenger];
        if (api != nil) {
            [channel setMessageHandler:^(id  message, FlutterReply reply) {
                NSMutableDictionary<NSString *, NSObject *> *wrapped = [NSMutableDictionary new];
                if ([message isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *params = message;
                    NSInteger playerId = [params[@"playerId"] integerValue];
                    NSInteger position = [params[@"position"] integerValue];
                    [api seekToWithPlayerId:playerId position:position];
                    wrapped[@"result"] = nil;
                } else {
                    wrapped[@"error"] = @{@"message": @"parse message error"};
                }
                reply(wrapped);
            }];
        } else {
            [channel setMessageHandler:nil];
        }
    }
    
    {
        FlutterBasicMessageChannel *channel =[FlutterBasicMessageChannel messageChannelWithName:@"io.github.wangyng.simple_audio_player.getCurrentPosition" binaryMessenger:messenger];
        if (api != nil) {
            [channel setMessageHandler:^(id  message, FlutterReply reply) {
                NSMutableDictionary<NSString *, NSObject *> *wrapped = [NSMutableDictionary new];
                if ([message isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *params = message;
                    NSInteger playerId = [params[@"playerId"] integerValue];
                    NSInteger result = [api getCurrentPositionWithPlayerId:playerId];
                    wrapped[@"result"] = @(result);
                } else {
                    wrapped[@"error"] = @{@"message": @"parse message error"};
                }
                reply(wrapped);
            }];
        } else {
            [channel setMessageHandler:nil];
        }
    }
    
    {
        FlutterBasicMessageChannel *channel =[FlutterBasicMessageChannel messageChannelWithName:@"io.github.wangyng.simple_audio_player.getDuration" binaryMessenger:messenger];
        if (api != nil) {
            [channel setMessageHandler:^(id  message, FlutterReply reply) {
                NSMutableDictionary<NSString *, NSObject *> *wrapped = [NSMutableDictionary new];
                if ([message isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *params = message;
                    NSInteger playerId = [params[@"playerId"] integerValue];
                    NSInteger result = [api getDurationWithPlayerId:playerId];
                    wrapped[@"result"] = @(result);
                } else {
                    wrapped[@"error"] = @{@"message": @"parse message error"};
                }
                reply(wrapped);
            }];
        } else {
            [channel setMessageHandler:nil];
        }
    }
    
    {
        FlutterBasicMessageChannel *channel =[FlutterBasicMessageChannel messageChannelWithName:@"io.github.wangyng.simple_audio_player.tryToGetAudioFocus" binaryMessenger:messenger];
        if (api != nil) {
            [channel setMessageHandler:^(id  message, FlutterReply reply) {
                NSMutableDictionary<NSString *, NSObject *> *wrapped = [NSMutableDictionary new];
                if ([message isKindOfClass:[NSDictionary class]]) {
                    BOOL result = [api tryToGetAudioFocus];
                    wrapped[@"result"] = @(result);
                } else {
                    wrapped[@"error"] = @{@"message": @"parse message error"};
                }
                reply(wrapped);
            }];
        } else {
            [channel setMessageHandler:nil];
        }
    }
    
    {
        FlutterBasicMessageChannel *channel =[FlutterBasicMessageChannel messageChannelWithName:@"io.github.wangyng.simple_audio_player.giveUpAudioFocus" binaryMessenger:messenger];
        if (api != nil) {
            [channel setMessageHandler:^(id  message, FlutterReply reply) {
                NSMutableDictionary<NSString *, NSObject *> *wrapped = [NSMutableDictionary new];
                if ([message isKindOfClass:[NSDictionary class]]) {
                    [api giveUpAudioFocus];
                    wrapped[@"result"] = nil;
                } else {
                    wrapped[@"error"] = @{@"message": @"parse message error"};
                }
                reply(wrapped);
            }];
        } else {
            [channel setMessageHandler:nil];
        }
    }

    {
        FlutterBasicMessageChannel *channel =[FlutterBasicMessageChannel messageChannelWithName:@"io.github.wangyng.simple_audio_player.showNotification" binaryMessenger:messenger];
        if (api != nil) {
            [channel setMessageHandler:^(id  message, FlutterReply reply) {
                NSMutableDictionary<NSString *, NSObject *> *wrapped = [NSMutableDictionary new];
                if ([message isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *params = message;
                    NSString *title = params[@"title"];
                    NSString *artist = params[@"artist"];
                    NSString *clipArt = params[@"clipArt"];
                    [api showNotificationWithTitle:title artist:artist clipArt:clipArt];
                    wrapped[@"result"] = nil;
                } else {
                    wrapped[@"error"] = @{@"message": @"parse message error"};
                }
                reply(wrapped);
            }];
        } else {
            [channel setMessageHandler:nil];
        }
    }

    {
        FlutterBasicMessageChannel *channel =[FlutterBasicMessageChannel messageChannelWithName:@"io.github.wangyng.simple_audio_player.updateNotification" binaryMessenger:messenger];
        if (api != nil) {
            [channel setMessageHandler:^(id  message, FlutterReply reply) {
                NSMutableDictionary<NSString *, NSObject *> *wrapped = [NSMutableDictionary new];
                if ([message isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *params = message;
                    BOOL showPlay = [params[@"showPlay"] boolValue];
                    NSString *title = params[@"title"];
                    NSString *artist = params[@"artist"];
                    NSString *clipArt = params[@"clipArt"];
                    [api updateNotificationWithShowPlay:showPlay title:title artist:artist clipArt:clipArt];
                    wrapped[@"result"] = nil;
                } else {
                    wrapped[@"error"] = @{@"message": @"parse message error"};
                }
                reply(wrapped);
            }];
        } else {
            [channel setMessageHandler:nil];
        }
    }

    {
        FlutterBasicMessageChannel *channel =[FlutterBasicMessageChannel messageChannelWithName:@"io.github.wangyng.simple_audio_player.cancelNotification" binaryMessenger:messenger];
        if (api != nil) {
            [channel setMessageHandler:^(id  message, FlutterReply reply) {
                NSMutableDictionary<NSString *, NSObject *> *wrapped = [NSMutableDictionary new];
                if ([message isKindOfClass:[NSDictionary class]]) {
                    [api cancelNotification];
                    wrapped[@"result"] = nil;
                } else {
                    wrapped[@"error"] = @{@"message": @"parse message error"};
                }
                reply(wrapped);
            }];
        } else {
            [channel setMessageHandler:nil];
        }
    }

}

@end
