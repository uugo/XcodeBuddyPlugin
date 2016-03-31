//
//  XcodeTheme.h
//  XcodeBuddy
//
//  Created by lizhen on 16/2/27.
//  Copyright © 2016年 craftman. All rights reserved.
//

#ifndef XcodeTheme_h
#define XcodeTheme_h

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

#define ThemeDirPath  @"/Library/Developer/Xcode/UserData/FontAndColorThemes/"
#define ThemeExtension @"dvtcolortheme"

@interface XcodeTheme : NSObject

+ (void) synXcodeThemeFile:(GCDAsyncSocket*) sock;

@end

#endif /* XcodeTheme_h */
