//
//  TMSerializable.h
//  FemaleSNS
//
//  Created by Li Feng on 12-8-18.
//  Copyright (c) 2013 Li Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMSerializableType.h"

// support basic data type, list and embeded TMSerializable type.
// Must avoid looped embedding.

#define TM_SERIALIZABLE_PROPERTY_PREFIX_STRING @"tm_class_name_of_"
#define TM_SERIALIZABLE_LIST_PREFIX_STRING @"tm_class_name_for_list_of_"
#define TM_SERIALIZABLE_ENUM_PREFIX_STRING @"tm_class_name_for_enum_"

#define TM_SERIALIZABLE_PROPERTY(property_attribute, property_type, property_name) \
@property (nonatomic, property_attribute) property_type property_name; \
- (NSString*)tm_class_name_of_##property_name;

#define TM_SERIALIZABLE_SYNTHESIZE(property_type, property_name) \
@synthesize property_name = _##property_name; \
- (NSString*)tm_class_name_of_##property_name \
{ \
typeof(_##property_name) temp;\
temp = (property_type) _##property_name;\
return @#property_type; \
}

#define TM_LIST_PROPERTY(property_type, property_name) \
@property (nonatomic, strong) NSMutableArray *property_name; \
- (NSString*)tm_class_name_for_list_of_##property_name;

#define TM_LIST_SYNTHESIZE(property_type, property_name) \
@synthesize property_name = _##property_name; \
- (NSString*)tm_class_name_for_list_of_##property_name \
{ \
return @#property_type; \
}

#define TM_SERIALIZABLE_ENUM(property_type, property_name) \
@property (nonatomic, assign) property_type property_name; \
- (NSString*)tm_class_name_for_enum_##property_name;

#define TM_SERIALIZABLE_ENUM_SYNTHESIZE(property_type, property_name) \
@synthesize property_name = _##property_name; \
- (NSString*)tm_class_name_for_enum_##property_name \
{ \
typeof(_##property_name) temp;\
temp = (property_type) _##property_name;\
return @#property_type; \
}

@protocol TMSerializable <NSObject>

@end

