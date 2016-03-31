
/*
 包装器
 
 */
#import <Foundation/Foundation.h>

@interface xcBuddyWeakObjectWrapper : NSObject

+ (instancetype) wrap:(NSObject *)object;

@property (nonatomic, weak, readonly) NSObject *wrappedObject;

@end
