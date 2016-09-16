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
#import "XcodeBuddyPlugin.h"
#import "CommContent.h"

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
    [_SendAllButton setAction:@selector(onDoTouchSendAllButton)];
    NSMutableString *stringOfTextView=[[self.sendedFilelistTextView textStorage] mutableString];
    [stringOfTextView setString:@""];
    if (clientSocketObject.clientSocket.isDisconnected){
        [stringOfTextView appendString:(NSString*)DisconnectedString];
    }
    [self.sendedFilelistTextView setEditable:NO];
}


- (void)insertStringToTextView:(NSString*) str {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableString *stringOfTextView=[[self.sendedFilelistTextView textStorage] mutableString];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
        NSString* dateTime = [formatter stringFromDate:[NSDate date]];
        [stringOfTextView appendString:[[NSString alloc] initWithFormat:@"[%@]:%@%@",dateTime, str,@"\n"]];
    });
}

- (void)startSending {
    fileIndex=0;
    [self.sendedFilelistTextView setString:@""];
    [self insertStringToTextView:(NSString*)StartString];
}

- (void)completeSending:(NSInteger)filesNumber {
    [self insertStringToTextView:[[NSString alloc] initWithFormat:@"%@%ld Files.",TotalString,(long)filesNumber] ];
}

- (void) onDoTouchCloseButton {
    [self close];
}

- (void) onDoTouchSendAllButton {
    if (clientSocketObject.clientSocket != nil){
        if (clientSocketObject.clientSocket.isDisconnected){
            connectAlert=[[ConnectAlert alloc] init:NO];
            [connectAlert runModal];
        }
       NSString* path=[XcodeBuddyPlugin WorkSpaceFilePath];
        if (path == nil){
            return;
        }
        [NSThread sleepForTimeInterval:0.5f];
        [self startSending];
        [self sendDirectory:path];
        [self completeSending:fileIndex];
    }

   
}

static NSInteger fileIndex=0;
- (void) sendDirectory:(NSString *)dirPath {
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *err=nil;
    NSArray *fileList=[fileManager contentsOfDirectoryAtPath:dirPath error:&err];
    NSString* workSpacePath=[XcodeBuddyPlugin WorkSpaceFilePath];
    if (workSpacePath == nil)
        return ;
    for (NSString* fileName in fileList) {
        //ignore hidden file
        if ([[fileName substringToIndex:1] isEqualToString:@"."]) {
            continue;
        }
        NSURL* filePath=[[NSURL alloc] initFileURLWithPath: [dirPath stringByAppendingPathComponent:fileName]];
        BOOL isDir=NO;
        if ([fileManager fileExistsAtPath:filePath.path isDirectory:&isDir]) {
            if (isDir) {
                NSString * ss=[filePath.path stringByReplacingOccurrencesOfString:workSpacePath withString:@""];
                if ([IgnordDirectoryName containsObject:ss])
                    continue;
                [self sendDirectory:filePath.path];
            }
            else {
                if ([CanSendedFileExtension containsObject: filePath.pathExtension]) {
                    [XcodeBuddyPlugin sendFile:filePath Type:kProjectFiles];
                    NSLog(@"send file:%@",filePath);
                    fileIndex++;
                    [self insertStringToTextView:[[NSString alloc] initWithFormat:@"%ld.%@",fileIndex,[filePath.path stringByReplacingOccurrencesOfString:workSpacePath withString:@""] ]];
                    [NSThread sleepForTimeInterval:0.05f];
                }
            }
        }
    }
    return;
}


@end
