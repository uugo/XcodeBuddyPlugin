//
//  DVTUserNotificationCenter+XcodeBuddy.m
//  XcodeBuddyPlugin
//
//  Created by lizhen on 16/3/20.
//  Copyright © 2016年 craftman. All rights reserved.
//

//#import <Foundation/NSError.h>
#import "DVTUserNotificationCenter+XcodeBuddy.h"
#import "JRSwizzle.h"
#import <objc/runtime.h>



@implementation DVTUserNotificationCenter (XcodeBuddy)

+ (void) load {
    NSError *error = nil;
    [self jr_swizzleMethod:@selector(userNotificationCenter:shouldPresentNotification:) withMethod:@selector(XcodeBuddy_userNotificationCenter:shouldPresentNotification:) error:&error];
    [self jr_swizzleMethod:@selector(userNotificationCenter:didActivateNotification:) withMethod:@selector(XcodeBuddy_userNotificationCenter:didActivateNotification:) error:&error];
}

- (BOOL)XcodeBuddy_userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
//    if ([notification.userInfo[VariablesViewFullCopyNewVersionNotification] boolValue]) {
//        return YES;
//    }
    return [self XcodeBuddy_userNotificationCenter:center shouldPresentNotification:notification];
}


- (void)XcodeBuddy_userNotificationCenter:(NSUserNotificationCenter *) center didActivateNotification:(NSUserNotification *) notification{
//    if ([notification.userInfo[]] boolValue) {
//        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@""]];
//    }
    [self XcodeBuddy_userNotificationCenter:center didActivateNotification:notification];
}

@end
