//
//  Singleton.h
//  XcodeBuddy
//
//  Created by lizhen on 16/3/28.
//  Copyright © 2016年 craftman. All rights reserved.
//

#ifndef Singleton_h
#define Singleton_h


#define DEFINE_SINGLETON_FOR_HEADER(className) \
\
+ (className *)shared##className;

#define DEFINE_SINGLETON_FOR_CLASS(className) \
\
+ (className *)shared##className { \
static className *shared##className = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
shared##className = [[self alloc] init]; \
}); \
return shared##className; \
}

#endif /* Singleton_h */
