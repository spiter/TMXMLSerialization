//
//  NSObject+PerformSelectorARCSafe.h
//  FemaleSNSDemo
//
//  Created by Li Feng on 12-11-14.
//  Copyright (c) 2013 Li Feng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PerformSelectorARCSafe)

- (id)performSelectorSafe:(SEL)aSelector;

@end
