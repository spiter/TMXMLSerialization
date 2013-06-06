//
//  TMXMLSerializer.h
//  FemaleSNS
//
//  Created by Li Feng on 12-8-18.
//  Copyright (c) 2013 Li Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMSerializer.h"

@interface TMXMLSerializer : NSObject <TMSerializer, TMDeserializer>

@property (nonatomic, strong) TMSerializableType *targetType;

- (void)assignPrimitiveValue:(NSString*)value forTarget:(id<TMSerializable>)target  withTargetType:(TMSerializableType*)targetType andValueType:(TMPropertyType*)valueType andPropertyName:(NSString*)propertyName;
- (void)assignSubObject:(id<TMSerializable>)subObj forTarget:(id<TMSerializable>)target withTargetType:(TMSerializableType*)targetType andValueType:(TMPropertyType*)valueType andPropertyName:(NSString*)propertyName;

- (id)initWithRootObjectClass:(Class) class;

@end
