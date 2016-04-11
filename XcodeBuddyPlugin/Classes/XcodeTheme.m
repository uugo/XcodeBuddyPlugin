//
//  XcodeTheme.m
//  XcodeBuddy
//
//  Created by lizhen on 16/2/27.
//  Copyright © 2016年 craftman. All rights reserved.
//



#import "XcodeTheme.h"
#import "CommContent.h"


@implementation XcodeTheme

+ (void) synXcodeThemeFile:(GCDAsyncSocket*) sock
{
    if (sock == nil) return;
    NSInteger i=0;
    NSError* err = nil;
    NSString* path=[NSHomeDirectory() stringByAppendingPathComponent:ThemeDirPath];

    for (NSString* fPath in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&err]) {
//        NSLog(@"fPath:%ld:%@",(long)i,fPath);
        if ([fPath.pathExtension isEqualToString:@"dvtcolortheme"]) {
            CommContent* commCont=[[CommContent alloc] init];
            commCont.type=kXcodeThemeFile;
            commCont.str=fPath;
            commCont.data=[[NSData alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:fPath]];
            commCont.length=commCont.data.length;
            [sock writeData:[NSKeyedArchiver archivedDataWithRootObject:commCont] withTimeout:-1 tag:0];
             [NSThread sleepForTimeInterval:0.01f];
        }
        i++;
    }
}


@end