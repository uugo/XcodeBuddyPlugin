//
//  XcodeBuddyPlugin.h
//  XcodeBuddyPlugin
//
//  Created by lizhen on 16/3/31.
//  Copyright © 2016年 crafthm. All rights reserved.
//

#import <AppKit/AppKit.h>

#import "GCDAsyncSocket.h"
#import "ConnectAlert.h"

FOUNDATION_EXPORT NSString *const MenuItemTitleOpenWithxcBuddy;
FOUNDATION_EXPORT NSString *const MenuItemTitleOpenWithExternalEditor;
FOUNDATION_EXPORT NSString *const ProjectNavigatorContextualMenu ;

FOUNDATION_EXPORT NSMenuItem *disconnectMenuItem;
FOUNDATION_EXPORT ConnectAlert* connectAlert;
FOUNDATION_EXPORT NSArray* IgnordDirectoryName;
FOUNDATION_EXPORT NSArray*  CanSendedFileExtension;

FOUNDATION_EXPORT NSString *const XcodeBuddyPluginNewVersionNotification;

@class XcodeBuddyPlugin;

static XcodeBuddyPlugin *sharedPlugin;

@interface XcodeBuddyPlugin : NSObject



+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic,copy,readonly) NSString* WorkSpaceFilePath;

- (void)doConnectMenuAction;
+(void) addToHostList:(NSString*) ip port:(UInt16)port;
+ (void) updateHostListMenuItemState:(NSString*) ipAndPort state:(BOOL) state;
+(NSString*) WorkSpaceFilePath;
+ (BOOL) sendFile:(NSURL*)filePath Type:(NSInteger) type;
@end