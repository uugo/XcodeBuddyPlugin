//
//  SendProjectFilesWindowController.h
//  XcodeBuddyPlugin
//
//  Created by lizhen on 16/4/1.
//  Copyright © 2016年 crafthm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

FOUNDATION_EXPORT NSString* StartString;
FOUNDATION_EXPORT NSString* EndString;
FOUNDATION_EXPORT NSString* TotalString;

@interface SendProjectFilesWindowController : NSWindowController
@property (strong) IBOutlet NSTextView *sendedFilelistTextView;
@property (strong) IBOutlet NSButton *closeButton;
@property (strong) IBOutlet NSButton *SendAllButton;

- (void)insertStringToTextView:(NSString*) str;
- (void)startSending;
- (void)completeSending:(NSInteger)filesNumber;

@end
