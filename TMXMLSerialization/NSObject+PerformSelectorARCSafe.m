//
//  NSObject+PerformSelectorARCSafe.m
//  FemaleSNSDemo
//
//  Created by Li Feng on 12-11-14.
//  Copyright (c) 2013 Li Feng. All rights reserved.
//

#import "NSObject+PerformSelectorARCSafe.h"

@implementation NSObject (PerformSelectorARCSafe)

- (id)performSelectorSafe:(SEL)aSelector
{
    NSMethodSignature *methodSig = [[self class] instanceMethodSignatureForSelector:aSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
    [invocation setSelector:aSelector];
    [invocation setTarget:self];
    [invocation invoke];
    id res = nil;
    NSAssert(methodSig.methodReturnLength <= sizeof(res), @"Return value is not an id.");
    [invocation getReturnValue:&res];
    return res;
}

@end
