//
//  AppDelegate.m
//  CrossShare
//
//  Created by mtjddnr on 2015. 3. 2..
//  Copyright (c) 2015년 mtjddnr. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

#pragma mark Entry
- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                       andSelector:@selector(handleEvent:withReplyEvent:)
                                                     forEventClass:kInternetEventClass
                                                        andEventID:kAEGetURL];
}
- (void)handleEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    NSLog(@"%@", url);
    
    exit(0);
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    if ([((NSNumber *)[notification userInfo][NSApplicationLaunchIsDefaultLaunchKey]) boolValue] == NO) return;
    
    NSLog(@"Command Line");
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    
    exit(0);
}

#pragma mark -

@end
