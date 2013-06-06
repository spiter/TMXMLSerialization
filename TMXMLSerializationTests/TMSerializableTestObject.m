//
//  TMSerializableTestObject.m
//  FemaleSNS
//
//  Created by  on 12-8-20.
//  Copyright (c) 2013 Li Feng. All rights reserved.
//

#import "TMSerializableTestObject.h"

@implementation TMSerializableTestSubObject

TM_SERIALIZABLE_ENUM_SYNTHESIZE(FSGender, test_gender)
TM_SERIALIZABLE_SYNTHESIZE(NSString*, test_str1)
TM_SERIALIZABLE_SYNTHESIZE(NSString*, test_str2)

@end

@implementation TMSerializableTestObject

TM_SERIALIZABLE_SYNTHESIZE(NSString*, test_str)
TM_SERIALIZABLE_SYNTHESIZE(float, test_float)
TM_SERIALIZABLE_SYNTHESIZE(NSInteger, test_integer)
TM_SERIALIZABLE_SYNTHESIZE(NSUInteger, test_uinteger)
TM_SERIALIZABLE_SYNTHESIZE(BOOL, test_bool)
TM_SERIALIZABLE_SYNTHESIZE(NSDate*, test_date)
TM_SERIALIZABLE_SYNTHESIZE(TMSerializableTestSubObject*, test_sub_object)
TM_LIST_SYNTHESIZE(NSInteger, test_list_interger)
TM_LIST_SYNTHESIZE(NSString*, test_list_string)
TM_LIST_SYNTHESIZE(TMSerializableTestSubObject*, test_list_sub_object);


@end

@implementation TMLoopTestAlpha

TM_SERIALIZABLE_SYNTHESIZE(NSString*, test_str)
TM_SERIALIZABLE_SYNTHESIZE(TMLoopTestBravo*, bravo)


@end

@implementation TMLoopTestBravo

TM_SERIALIZABLE_SYNTHESIZE(NSString*, test_str)
TM_SERIALIZABLE_SYNTHESIZE(TMLoopTestAlpha*, alpha)


@end

@implementation TMReservedKeywordObject

TM_SERIALIZABLE_SYNTHESIZE(NSString*, dataNew);


@end