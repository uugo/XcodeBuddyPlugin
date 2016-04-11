//
//  SendProjectFilesWindowController.m
//  XcodeBuddyPlugin
//
//  Created by lizhen on 16/4/1.
//  Copyright © 2016年 crafthm. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "SendProjectFilesWindowController.h"
#import "ClientSocket.h"

NSString const *StartString=@"Begin to send files.";
NSString const *EndString=@"End.";
NSString const *TotalString=@"Total:";
NSString const *DisconnectedString=@"XcodeBuddy can not connect any server(xcBuddy App).";

@interface SendProjectFilesWindowController()


@end

@implementation SendProjectFilesWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [_closeButton setAction:@selector(onDoTouchCloseButton)];
    NSMutableString *stringOfTextView=[[self.sendedFilelistTextView textStorage] mutableString];
    [stringOfTextView setString:@""];
    if (clientSocketObject.clientSocket.isDisconnected){
        [stringOfTextView appendString:(NSString*)DisconnectedString];
    }
    [self.sendedFilelistTextView setEditable:NO];
}


- (void)insertStringToTextView:(NSString*) str {
    NSMutableString *stringOfTextView=[[self.sendedFilelistTextView textStorage] mutableString];
    [stringOfTextView appendString:[[NSString alloc] initWithFormat:@"%@%@",str,@"\n"]];
}

- (void)startSending {
    [self insertStringToTextView:(NSString*)StartString];
}

- (void)completeSending:(NSInteger)filesNumber {
    [self insertStringToTextView:[[NSString alloc] initWithFormat:@"%@%ld Files.",TotalString,(long)filesNumber] ];
}

- (void) onDoTouchCloseButton {
    [self close];
}



@end
