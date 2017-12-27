//
//  CocoaProxy.m
//  CocoaProxy
//
//  Created by Arnaud Dorgans on 27/12/2017.
//

#import "CocoaProxy.h"

@implementation CocoaProxy

- (instancetype _Nonnull)init:(nonnull NSArray<NSObject*>*)proxies {
    [self.proxies addObjectsFromArray: proxies];
    return self;
}

- (instancetype _Nonnull)init {
    return [self init: @[]];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return ([self methodSignatureForSelector: aSelector] != nil);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    for (NSObject* proxy in self.proxies) {
        if ([proxy respondsToSelector: aSelector]) {
            return [proxy methodSignatureForSelector: aSelector];
        }
    }
    return nil;
}

- (NSArray<NSObject *> *_Nonnull)proxiesForSelector:(SEL _Nonnull )aSelector
{
    if (self.proxyFilter) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return self.proxyFilter(evaluatedObject, aSelector);
        }];
        return [self.proxies filteredArrayUsingPredicate: predicate];
    }
    return self.proxies;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    for (NSObject* proxy in [self proxiesForSelector: invocation.selector]) {
        [self invokeInvocation: invocation onProxy: proxy];
    }
}

- (BOOL)invokeInvocation:(NSInvocation *)invocation onProxy:(id<NSObject>)proxy
{
    if ([proxy respondsToSelector: invocation.selector]) {
        [invocation invokeWithTarget: proxy];
        return YES;
    }
    return NO;
}

@end
