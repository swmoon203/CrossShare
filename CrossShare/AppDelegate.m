//
//  AppDelegate.m
//  CrossShare
//
//  Created by mtjddnr on 2015. 3. 2..
//  Copyright (c) 2015년 mtjddnr. All rights reserved.
//

#import "AppDelegate.h"
NSString * const ApplicationOpenURLKey = @"ApplicationOpenURLKey";

@implementation AppDelegate {
    NSInteger shareCount;
}

#pragma mark Entry
- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                       andSelector:@selector(handleEvent:withReplyEvent:)
                                                     forEventClass:kInternetEventClass
                                                        andEventID:kAEGetURL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ApplicationOpenURLKey];
}
- (void)handleEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSString *url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    if (url != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:url forKey:ApplicationOpenURLKey];
    }
    [self handleArguments];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSNumber *isDefaultLaunch = [notification userInfo][NSApplicationLaunchIsDefaultLaunchKey];
    [[NSUserDefaults standardUserDefaults] setObject:isDefaultLaunch forKey:NSApplicationLaunchIsDefaultLaunchKey];
    if ([isDefaultLaunch boolValue] == NO) return;
    [self handleArguments];
}

#pragma mark -
#pragma mark Handle Arguments
/*
    open CrossShare.app --args -type twitter -text test -url http://google.com
    ./CrossShare.app/Contents/MacOS/CrossShare -type twitter -text "test test" -url "http://google.com"
    open "crossshare://twitter?text=test test&url=http://google.com"
 */
- (NSDictionary *)getArguments {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    
    NSArray *keys = @[ @"type", @"text", @"url", @"image" ];
    NSDictionary *services = @{
                               @"airdrop": NSSharingServiceNameSendViaAirDrop,
                               @"email": NSSharingServiceNameComposeEmail,
                               @"message": NSSharingServiceNameComposeMessage,
                               @"twitter": NSSharingServiceNamePostOnTwitter,
                               @"facebook": NSSharingServiceNamePostOnFacebook
                               };
    
    if ([userDefaults objectForKey:ApplicationOpenURLKey] != nil) {
        NSURL *url = [NSURL URLWithString:[userDefaults objectForKey:ApplicationOpenURLKey]];
        [userDefaults removeObjectForKey:ApplicationOpenURLKey];
        
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
        values[@"type"] = [urlComponents host];
        for (NSURLQueryItem *item in urlComponents.queryItems) {
            if ([keys containsObject:item.name]) values[item.name] = item.value;
        }
    } else {
        [values setDictionary:[userDefaults dictionaryWithValuesForKeys:keys]];
        [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isKindOfClass:[NSNull class]]) [values removeObjectForKey:key];
            [userDefaults removeObjectForKey:key];
        }];
    }
    
    if (values[@"type"] == nil) return nil;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"values"] = [NSMutableArray array];
    param[@"service"] = services[values[@"type"]];
    [values removeObjectForKey:@"type"];
    
    if (values[@"url"] != nil) values[@"url"] = [NSURL URLWithString:values[@"url"]];
    if (values[@"image"] != nil) values[@"image"] = [NSURL fileURLWithPath:values[@"image"]];
    
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [param[@"values"] addObject:obj];
    }];
    
    return param;
}

- (void)handleArguments {
    NSDictionary *param = [self getArguments];
    if (param == nil) return [self clearExit];
    
    NSSharingService *sharingService = [NSSharingService sharingServiceNamed:param[@"service"]];
    sharingService.delegate = self;
    
    NSArray *items = param[@"values"];
    if ([sharingService canPerformWithItems:items]) {
        [sharingService performWithItems:items];
        shareCount++;
    } else {
        [self clearExit];
    }
}

#pragma mark - NSSharingServiceDelegate

- (void)sharingService:(NSSharingService *)sharingService didShareItems:(NSArray *)items {
    shareCount--;
    [self clearExit];
}

- (void)sharingService:(NSSharingService *)sharingService didFailToShareItems:(NSArray *)items error:(NSError *)error {
    shareCount--;
    [self clearExit];
}

#pragma mark - Exit
- (void)clearExit {
    if (shareCount <= 0) exit(0);
}

@end
