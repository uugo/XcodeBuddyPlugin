

#import "xcBuddyWeakObjectWrapper.h"

@interface xcBuddyWeakObjectWrapper ()
@property (nonatomic, weak) NSObject *wrappedObject;
@end

@implementation xcBuddyWeakObjectWrapper

+ (instancetype)wrap:(NSObject *)object
{
  xcBuddyWeakObjectWrapper *wrapper = [self new];
  wrapper.wrappedObject = object;
  return wrapper;
}

- (NSUInteger)hash
{
  return self.wrappedObject.hash;
}

@end
