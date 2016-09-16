//
//  HelpWindowController.h
//  XcodeBuddyPlugin
//
//  Created by lizhen on 16/6/17.
//  Copyright © 2016年 crafthm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HelpWindowController : NSWindowController

@property (strong) IBOutlet NSTextField *currentVersion;
@property (strong) IBOutlet NSButton *helpButton;
@property (strong) IBOutlet NSButton *okButton;

@end
