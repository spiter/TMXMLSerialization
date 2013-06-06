//
//  TMSerializableType.h
//  FemaleSNS
//
//  Created by Li Feng on 12-8-21.
//  Copyright (c) 2013 Li Feng. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMSerializableType;

@interface TMPropertyType : NSObject

@property (nonatomic, strong) TMSerializableType* propertyType;
@property (nonatomic, assign) BOOL isListProperty;
@property (nonatomic, assign) BOOL isEnumProperty;
- (id)initWithSerializableType:(TMSerializableType*)type andIsList:(BOOL)isList andIsEnum:(BOOL)isEnum;

@end

@interface TMSerializableType : NSObject

@property (nonatomic, copy, readonly) NSString *typeStr;
@property (nonatomic, unsafe_unretained, readonly) Class typeClass;
@property (nonatomic, strong, readonly) NSDictionary *propertyTypes;

+ (TMSerializableType*)typeWithStr:(NSString*)typestr;
+ (TMSerializableType*)typeWithClass:(Class)class;

- (BOOL)isSerializableType;
- (BOOL)isPrimitiveType;

@end
