//
//  HelpWindowController.m
//  XcodeBuddyPlugin
//
//  Created by lizhen on 16/6/17.
//  Copyright © 2016年 crafthm. All rights reserved.
//

#import "HelpWindowController.h"
#import "UserInfoKeys.h"

@interface HelpWindowController ()

@end

@implementation HelpWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
     NSString *lastVersion = [[NSUserDefaults standardUserDefaults] stringForKey:kLatestVersion];
    if (lastVersion != nil)
        _currentVersion.stringValue = lastVersion;
    else
        _currentVersion.stringValue = @"1.0";
    [_helpButton setAction:@selector(onClickHelpButton)];
    [_okButton setAction:@selector(onClickOKButton)];
}

-(void) onClickHelpButton {
   NSURL *web_url = [NSURL URLWithString:@"https://github.com/uugo/XcodeBuddyPlugin"];
  [[NSWorkspace sharedWorkspace] openURL:web_url];
}

-(void) onClickOKButton {
    [self close];
}

@end
