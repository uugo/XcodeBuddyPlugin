//
//  CommContent.m
//  xcBuddy
//
//  Created by lizhen on 16/2/28.
//  Copyright © 2016年 craftman. All rights reserved.
//

#import "CommContent.h"

@implementation CommContent

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self == [super init]) {
        self.type=[aDecoder decodeIntegerForKey:key_TYPE];
        self.length=[aDecoder decodeIntegerForKey:key_LENGTH];
        self.str=[aDecoder decodeObjectForKey:key_STR];
        self.data=[aDecoder decodeObjectForKey:key_DATA];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.type forKey:key_TYPE];
    [aCoder encodeInteger:self.length forKey:key_LENGTH];
    [aCoder encodeObject:self.str forKey:key_STR];
    [aCoder encodeObject:self.data forKey:key_DATA];
}

@end


