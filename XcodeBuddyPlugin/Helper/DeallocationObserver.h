//


#import <Foundation/Foundation.h>

@interface DeallocationObserver : NSObject

@property (nonatomic, weak) id observedObject;
@property (nonatomic, copy) void (^deallocBlock)(id observedObject);

@end
