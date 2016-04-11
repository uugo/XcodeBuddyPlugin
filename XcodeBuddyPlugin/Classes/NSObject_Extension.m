//
//  NSObject_Extension.m
//  XcodeBuddy
//
//  Created by lizhen on 16/2/14.
//  Copyright © 2016年 craftman. All rights reserved.
//


#import "NSObject_Extension.h"
#import "XcodeBuddyPlugin.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[XcodeBuddyPlugin alloc] initWithBundle:plugin];
        });
    }
}
//-(void)dumpWithIndent:(NSString *)indent {
//    NSString *class = NSStringFromClass([self class]);
//    NSString *info = @"";
//    if ([self respondsToSelector:@selector(title)]) {
//        NSString *title = [self performSelector:@selector(title)];
//        if (title != nil && [title length] > 0) {
//            info = [info stringByAppendingFormat:@" title=%@", title];
//        }
//    }
//    if ([self respondsToSelector:@selector(stringValue)]) {
//        NSString *string = [self performSelector:@selector(stringValue)];
//        if (string != nil && [string length] > 0) {
//            info = [info stringByAppendingFormat:@" stringValue=%@", string];
//        }
//    }
//    NSString *tooltip = [self toolTip];
//    if (tooltip != nil && [tooltip length] > 0) {
//        info = [info stringByAppendingFormat:@" tooltip=%@", tooltip];
//    }
//    
//    NSLog(@"%@%@%@", indent, class, info);
//    
//    if ([[self subviews] count] > 0) {
//        NSString *subIndent = [NSString stringWithFormat:@"%@%@", indent, ([indent length]/2)%2==0 ? @"| " : @": "];
//        for (NSView *subview in [self subviews]) {
//            [subview dumpWithIndent:subIndent];
//        }
//    }
//}
@end
