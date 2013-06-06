//
//  TMSerializableTestObject.h
//  FemaleSNS
//
//  Created by Li Feng on 12-8-20.
//  Copyright (c) 2013 Li Feng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TMSerializable.h"

typedef enum {
    kGenderUnknown = 0,
    kGenderMale = 1,
    kGenderFemale = 2
}FSGender;

@interface TMSerializableTestSubObject : NSObject <TMSerializable>

TM_SERIALIZABLE_ENUM(FSGender, test_gender)
TM_SERIALIZABLE_PROPERTY(copy, NSString*, test_str1)
TM_SERIALIZABLE_PROPERTY(copy, NSString*, test_str2)

@end

@interface TMSerializableTestObject : NSObject <TMSerializable>

TM_SERIALIZABLE_PROPERTY(copy, NSString*, test_str)
TM_SERIALIZABLE_PROPERTY(assign, float, test_float)
TM_SERIALIZABLE_PROPERTY(assign, NSInteger, test_integer)
TM_SERIALIZABLE_PROPERTY(assign, NSUInteger, test_uinteger)
TM_SERIALIZABLE_PROPERTY(assign, BOOL, test_bool)
TM_SERIALIZABLE_PROPERTY(strong, NSDate*, test_date)
// more basic type to test
TM_SERIALIZABLE_PROPERTY(strong, TMSerializableTestSubObject*, test_sub_object)

TM_LIST_PROPERTY(NSInteger, test_list_interger);
TM_LIST_PROPERTY(NSString*, test_list_string);
TM_LIST_PROPERTY(TMSerializableTestSubObject*, test_list_sub_object);

@end

@class TMLoopTestBravo;

@interface TMLoopTestAlpha : NSObject <TMSerializable>

TM_SERIALIZABLE_PROPERTY(copy, NSString*, test_str);
TM_SERIALIZABLE_PROPERTY(strong, TMLoopTestBravo*, bravo);

@end

@interface TMLoopTestBravo : NSObject <TMSerializable>

TM_SERIALIZABLE_PROPERTY(copy, NSString*, test_str);
TM_SERIALIZABLE_PROPERTY(strong, TMLoopTestAlpha*, alpha);

@end

@interface TMReservedKeywordObject : NSObject <TMSerializable>

TM_SERIALIZABLE_PROPERTY(copy, NSString*, dataNew);

@end
