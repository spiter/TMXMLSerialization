//
//  TMSerializer.h
//  FemaleSNS
//
//  Created by Li Feng on 12-8-18.
//  Copyright (c) 2013 Li Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMSerializable.h"

@protocol TMSerializer <NSObject>

- (NSData*)serialize:(id<TMSerializable>)object; //const
- (NSData*)serialize:(id<TMSerializable>)object withRootName:(NSString *)rootName;

@end

@protocol TMDeserializer <NSObject>

- (NSError*)deserialize:(NSData*)data intoObject:(id<TMSerializable>)target; //const

@end