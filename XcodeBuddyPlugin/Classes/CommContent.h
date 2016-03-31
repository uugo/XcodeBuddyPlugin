//
//  CommContent.h
//  XcodeBuddy
//
//  Created by lizhen on 16/2/28.
//  Copyright © 2016年 craftman. All rights reserved.
//

#ifndef CommContent_h
#define CommContent_h

#import <Foundation/Foundation.h>

#define kFileContent 1
#define kHeartBeat 2
#define kXcodeThemeFile 3
#define kProjectFiles 4

#define  key_TYPE @"ktype"
#define  key_LENGTH @"klength"
#define  key_STR @"kString"
#define  key_DATA @"kData"

@interface CommContent :NSObject<NSCoding>
    @property NSInteger type;
    @property NSInteger length;
    @property NSString* str;
    @property NSData*   data;
@end





#endif /* CommContent_h */
