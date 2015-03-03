//
//  main.m
//  CrossShare
//
//  Created by mtjddnr on 2015. 3. 2..
//  Copyright (c) 2015년 mtjddnr. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *application = [NSApplication sharedApplication];
        AppDelegate *app = [[AppDelegate alloc] init];
        application.delegate = app;
        [application run];
    }
    return 0;
}
