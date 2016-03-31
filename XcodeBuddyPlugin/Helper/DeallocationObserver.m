//


#import "DeallocationObserver.h"
#import <objc/runtime.h>

@interface DeallocationObserver ()
@end

@implementation DeallocationObserver

- (void)dealloc
{
  !self.deallocBlock ?: self.deallocBlock(self.observedObject);
}

- (void)setObservedObject:(id)observedObject
{
  _observedObject = observedObject;
  objc_setAssociatedObject(observedObject, _cmd, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
