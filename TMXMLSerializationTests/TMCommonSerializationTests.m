//
//  TMCommonSerializationTests.m
//  TMCommonSerializationTests
//
//  Created by Li Feng on 12-8-21.
//  Copyright (c) 2013 Li Feng. All rights reserved.
//

#import "TMCommonSerializationTests.h"
#import "TMSerializableTestObject.h"
#import "TMSerializableType.h"

@implementation TMCommonSerializationTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testPropertyTypes
{
    TMSerializableType *typeInfo = [TMSerializableType typeWithStr:@"TMSerializableTestSubObject"];
    STAssertEquals([typeInfo.propertyTypes count], (NSUInteger)3, @"Properties' num wrong.");
    TMPropertyType *strInfo = [typeInfo.propertyTypes objectForKey:@"test_str2"];
    STAssertNotNil(strInfo, @"test_str2 info missing.");
    STAssertTrue([strInfo.propertyType isPrimitiveType], @"NSString shuold be a primitive type.");
    STAssertNil(strInfo.propertyType.propertyTypes, @"Primitive type shuold have no sub types.");
    STAssertFalse(strInfo.isListProperty, @"test_str2 shuold not be a list property.");
}

- (void)testEmbededPropertyTypes
{
    TMSerializableType *typeInfo = [TMSerializableType typeWithStr:@"TMSerializableTestObject"];
    STAssertEquals([typeInfo.propertyTypes count], (NSUInteger)10, @"Properties' num wrong.");
    
    TMPropertyType *floatInfo = [typeInfo.propertyTypes objectForKey:@"test_float"];
    STAssertNil(floatInfo.propertyType.propertyTypes, @"Float should have no sub types.");
    STAssertFalse(floatInfo.propertyType.isSerializableType, @"Float should not be a serializable type.");
    STAssertFalse(floatInfo.isListProperty, @"test_float should not be a list type.");
    
    TMPropertyType *strListInfo = [typeInfo.propertyTypes objectForKey:@"test_list_string"];
    STAssertNil(strListInfo.propertyType.propertyTypes, @"NSString should have no sub types.");
    STAssertFalse(strListInfo.propertyType.isSerializableType, @"Float should not be a serializable type.");
    STAssertTrue(strListInfo.isListProperty, @"strListInfo should be a list type.");
    
    TMPropertyType *subObjInfo = [typeInfo.propertyTypes objectForKey:@"test_sub_object"];
    STAssertNotNil(subObjInfo.propertyType.propertyTypes, @"TMSerializableTestSubObject should have sub types.");
    STAssertTrue(subObjInfo.propertyType.isSerializableType, @"TMSerializableTestSubObject should be a serializable type.");
    STAssertFalse(subObjInfo.isListProperty, @"subObjInfo should not be a list type.");
    
    TMPropertyType *subListInfo = [typeInfo.propertyTypes objectForKey:@"test_list_sub_object"];
    STAssertNotNil(subListInfo.propertyType.propertyTypes, @"TMSerializableTestSubObject should have sub types.");
    STAssertTrue(subListInfo.propertyType.isSerializableType, @"TMSerializableTestSubObject should be a serializable type.");
    STAssertTrue(subListInfo.isListProperty, @"test_list_sub_object should be a list type.");
}

- (void)testLoopEmbededPropertyType
{
    TMSerializableType *typeInfo = [TMSerializableType typeWithStr:@"TMLoopTestAlpha"];
    STAssertEquals([typeInfo.propertyTypes count], (NSUInteger)2, @"Properties' num wrong.");
}

@end
