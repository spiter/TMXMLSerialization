//
//  TMXMLSerializerTest.m
//  FemaleSNS
//
//  Created by Li Feng on 12-8-18.
//  Copyright (c) 2013 Li Feng. All rights reserved.
//

#import "TMXMLSerializerTest.h"

#import "TMXMLSerializer.h"
#import "TMSerializableTestObject.h"

#import "objc/runtime.h"

@implementation TMXMLSerializerTest

#pragma mark compare helper
- (void)compare:(id<TMSerializable>)object withTarget:(id<TMSerializable>)target
{
    TMSerializableType *type = [TMSerializableType typeWithClass:[object class]];
    [type.propertyTypes enumerateKeysAndObjectsUsingBlock:^(NSString *key, TMPropertyType *subType, BOOL* stop){
        SEL selector = NSSelectorFromString(key);
        if ([object respondsToSelector:selector]) {
            if ([subType isListProperty]) {
                NSMutableArray *list = [(NSObject *)object valueForKey:key]; //performSelector:selector];
                NSMutableArray *targetList = [(NSObject *)target valueForKey:key]; //performSelector:selector];
                [list enumerateObjectsUsingBlock:^(id<TMSerializable> listObject, NSUInteger idx, BOOL *listStop) {
                    id<TMSerializable> targetObject = [targetList objectAtIndex:idx];
                    if (![listObject conformsToProtocol:@protocol(TMSerializable)]) {
                        if ([subType.propertyType.typeStr isEqualToString:@"NSString"] || [subType.propertyType.typeStr isEqualToString:@"NSDate"]) {
                            STAssertEqualObjects(listObject, targetObject, @"test failed.");
                        } else {
                            STAssertEquals([(NSNumber *)listObject floatValue], [(NSNumber *)targetObject floatValue], @"test failed");
                        }
                    } else {
                        [self compare:listObject withTarget:targetObject];
                    }
                }];
            } else {
                if ([subType.propertyType isSerializableType]) {
                    id subObject = [(NSObject *)object valueForKey:key]; //performSelector:selector];
                    id targetSubObject = [(NSObject *)target valueForKey:key];//performSelector:selector];
                    [self compare:subObject withTarget:targetSubObject];
                }
                else {
                    if ([subType.propertyType.typeStr isEqualToString:@"NSString"] || [subType.propertyType.typeStr isEqualToString:@"NSDate"]) {
                        id subObject = [(NSObject *)object valueForKey:key];//performSelector:selector];
                        id targetSubObject = [(NSObject *)target valueForKey:key];//performSelector:selector];
                        STAssertEqualObjects(subObject, targetSubObject, @"test failed.");
                    } else {
                        STAssertEquals([[(NSObject *)object valueForKey:key] floatValue], [[(NSObject *)target valueForKey:key] floatValue], @"test failed");
                    }
                }
            }
        }
    }];
}

#pragma mark -
#pragma mark Deserialization
- (void)testStringObjectDeserialization
{
    static NSString* testXML = 
    @"<root><test_str1>TEST_STRING 123</test_str1><test_str2></test_str2></root>";
    TMXMLSerializer *xmlSerializer = [[TMXMLSerializer alloc] initWithRootObjectClass:TMSerializableTestSubObject.class];
    
    TMSerializableTestSubObject *obj = [[TMSerializableTestSubObject alloc] init];
    NSError* e = [xmlSerializer deserialize:[testXML dataUsingEncoding:NSUTF8StringEncoding] intoObject:obj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    STAssertEqualObjects(@"TEST_STRING 123", obj.test_str1, @"test str 1 failed.");
    STAssertEqualObjects(@"", obj.test_str2, @"test str 2 failed.");
}

- (void)testComplexStringObjectDeserialization
{
    static NSString* testXML =
    @"<root><test_str1>Aoyama-itch ōme Station</test_str1></root>";
    TMXMLSerializer *xmlSerializer = [[TMXMLSerializer alloc] initWithRootObjectClass:TMSerializableTestSubObject.class];
    
    TMSerializableTestSubObject *obj = [[TMSerializableTestSubObject alloc] init];
    NSError* e = [xmlSerializer deserialize:[testXML dataUsingEncoding:NSUTF8StringEncoding] intoObject:obj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    STAssertEqualObjects(@"Aoyama-itch ōme Station", obj.test_str1, @"test str 1 failed.");
}

- (void)testKeyMissingDeserialization
{
    static NSString* testXML = 
    @"<root><test_str2>TEST_STRING 456</test_str2><testFFF>asdfasdf</testFFF></root>";
    TMXMLSerializer *xmlSerializer = [[TMXMLSerializer alloc] initWithRootObjectClass:TMSerializableTestSubObject.class];
    
    TMSerializableTestSubObject *obj = [[TMSerializableTestSubObject alloc] init];
    obj.test_str1 = @"123";
    obj.test_str2 = @"456";
    NSError* e = [xmlSerializer deserialize:[testXML dataUsingEncoding:NSUTF8StringEncoding] intoObject:obj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    STAssertEqualObjects(@"123", obj.test_str1, @"test str 1 failed.");
    STAssertEqualObjects(@"TEST_STRING 456", obj.test_str2, @"test str 2 failed.");
}

- (void)testScalarDeserialization
{
    static NSString* testXML = 
    @"<root><test_float>456.5</test_float><test_integer>-789</test_integer><test_uinteger>123</test_uinteger></root>";
    TMXMLSerializer *xmlSerializer = [[TMXMLSerializer alloc] initWithRootObjectClass:TMSerializableTestObject.class];
    
    TMSerializableTestObject *obj = [[TMSerializableTestObject alloc] init];
    NSError* e = [xmlSerializer deserialize:[testXML dataUsingEncoding:NSUTF8StringEncoding] intoObject:obj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    STAssertEqualsWithAccuracy(obj.test_float, (float)456.5, 0.0001, @"Float deserialization failed.");
    STAssertEquals(obj.test_integer, (NSInteger)-789, @"Integer deserialization failed.");
    STAssertEquals(obj.test_uinteger, (NSUInteger)123, @"Unsigned Integer deserialization failed.");
}

- (void)testBOOLDeserialization
{
    static NSString* testTrueXML = 
    @"<root><test_bool>true</test_bool></root>";
    static NSString* testFalseXML = 
    @"<root><test_bool>false</test_bool></root>";
    TMXMLSerializer *xmlSerializer = [[TMXMLSerializer alloc] initWithRootObjectClass:TMSerializableTestObject.class];
    
    TMSerializableTestObject *obj = [[TMSerializableTestObject alloc] init];
    
    NSError* e = [xmlSerializer deserialize:[testTrueXML dataUsingEncoding:NSUTF8StringEncoding] intoObject:obj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    STAssertTrue(obj.test_bool, @"Boolean deserialization failed.");
    
    e = [xmlSerializer deserialize:[testFalseXML dataUsingEncoding:NSUTF8StringEncoding] intoObject:obj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    STAssertTrue(!obj.test_bool, @"Boolean deserialization failed.");
}

- (void)testDateDeserialization
{
    static NSString* testXML = 
    @"<root><test_date>Fri Aug 10 16:50:33 +0800 2012</test_date></root>";
    TMXMLSerializer *xmlSerializer = [[TMXMLSerializer alloc] initWithRootObjectClass:TMSerializableTestObject.class];
    
    TMSerializableTestObject *obj = [[TMSerializableTestObject alloc] init];
    NSError* e = [xmlSerializer deserialize:[testXML dataUsingEncoding:NSUTF8StringEncoding] intoObject:obj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
 
    STAssertEquals((int)[obj.test_date timeIntervalSince1970], 1344588633, @"Date deserialization failed.");
}

- (void)testAttributeDeserialization
{
    static NSString* testXML = 
    @"<root test_float=\"456.5\"><test_integer>789</test_integer></root>";
    TMXMLSerializer *xmlSerializer = [[TMXMLSerializer alloc] initWithRootObjectClass:TMSerializableTestObject.class];
    
    TMSerializableTestObject *obj = [[TMSerializableTestObject alloc] init];
    NSError* e = [xmlSerializer deserialize:[testXML dataUsingEncoding:NSUTF8StringEncoding] intoObject:obj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    STAssertEqualsWithAccuracy(obj.test_float, (float)456.5, 0.0001, @"Float deserialization failed.");
    STAssertEquals(obj.test_integer, (NSInteger)789, @"Integer deserialization failed.");
}

- (void)testSubObjectDeserialization
{
    static NSString* testXML = 
    @"<root><test_sub_object><test_str1>789str</test_str1></test_sub_object></root>";
    TMXMLSerializer *xmlSerializer = [[TMXMLSerializer alloc] initWithRootObjectClass:TMSerializableTestObject.class];
    
    TMSerializableTestObject *obj = [[TMSerializableTestObject alloc] init];
    NSError* e = [xmlSerializer deserialize:[testXML dataUsingEncoding:NSUTF8StringEncoding] intoObject:obj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    STAssertNotNil(obj.test_sub_object, @"SubObject should not be nil.");
    STAssertEqualObjects(obj.test_sub_object.test_str1, @"789str", @"SubObject string value deserialization failed.");
}

- (void)testSubOjectWithClosedTagDeserialization
{
    static NSString* testXML = 
    @"<root><test_sub_object test_str1=\"789str\"/></root>";
    TMXMLSerializer *xmlSerializer = [[TMXMLSerializer alloc] initWithRootObjectClass:TMSerializableTestObject.class];
    
    TMSerializableTestObject *obj = [[TMSerializableTestObject alloc] init];
    NSError* e = [xmlSerializer deserialize:[testXML dataUsingEncoding:NSUTF8StringEncoding] intoObject:obj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    STAssertNotNil(obj.test_sub_object, @"SubObject should not be nil.");
    STAssertEqualObjects(obj.test_sub_object.test_str1, @"789str", @"SubObject string value deserialization failed.");
}

- (void)testStringListDeserialization
{
    static NSString* testXML = 
    @"<root><test_list_string>789str</test_list_string><test_list_string>str123</test_list_string></root>";
    TMXMLSerializer *xmlSerializer = [[TMXMLSerializer alloc] initWithRootObjectClass:TMSerializableTestObject.class];
    
    TMSerializableTestObject *obj = [[TMSerializableTestObject alloc] init];
    NSError* e = [xmlSerializer deserialize:[testXML dataUsingEncoding:NSUTF8StringEncoding] intoObject:obj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    STAssertEquals([obj.test_list_string count], (NSUInteger)2, @"String list should contains 2 strings.");
    STAssertEqualObjects([obj.test_list_string objectAtIndex:0], @"789str", @"First string value deserialization failed.");
    STAssertEqualObjects([obj.test_list_string objectAtIndex:1], @"str123", @"Second string value deserialization failed.");
}

- (void)testScalarListDeserialization
{
    static NSString* testXML = 
    @"<root><test_list_interger>789</test_list_interger><test_list_interger>123</test_list_interger><test_list_float>456.109</test_list_float></root>";
    TMXMLSerializer *xmlSerializer = [[TMXMLSerializer alloc] initWithRootObjectClass:TMSerializableTestObject.class];
    
    TMSerializableTestObject *obj = [[TMSerializableTestObject alloc] init];
    NSError* e = [xmlSerializer deserialize:[testXML dataUsingEncoding:NSUTF8StringEncoding] intoObject:obj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    STAssertEquals([obj.test_list_interger count], (NSUInteger)2, @"String list should contains 2 strings.");
    STAssertEquals([[obj.test_list_interger objectAtIndex:0] integerValue], (NSInteger)789, @"First integer value deserialization failed.");
    STAssertEquals([[obj.test_list_interger objectAtIndex:1] integerValue], (NSInteger)123, @"Second integer value deserialization failed.");
}

- (void)testSubObjectListDeserialization
{
    static NSString* testXML = 
    @"<root><test_list_sub_object><test_str1>789str</test_str1></test_list_sub_object><test_list_sub_object><test_str2>str123</test_str2></test_list_sub_object></root>";
    TMXMLSerializer *xmlSerializer = [[TMXMLSerializer alloc] initWithRootObjectClass:TMSerializableTestObject.class];
    
    TMSerializableTestObject *obj = [[TMSerializableTestObject alloc] init];
    NSError* e = [xmlSerializer deserialize:[testXML dataUsingEncoding:NSUTF8StringEncoding] intoObject:obj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    STAssertEquals([obj.test_list_sub_object count], (NSUInteger)2, @"String list should contains 2 sub objects.");
    STAssertEqualObjects([[obj.test_list_sub_object objectAtIndex:0] test_str1], @"789str", @"First object value deserialization failed.");
    STAssertEqualObjects([[obj.test_list_sub_object objectAtIndex:1] test_str2], @"str123", @"Second object value deserialization failed.");
}

- (void)testLoopSubObjectDeserialization
{
    static NSString* testXML = 
    @"<root><bravo><alpha><test_str>hahaha</test_str></alpha></bravo><test_str>wowowo</test_str></root>";
    TMXMLSerializer *xmlSerializer = [[TMXMLSerializer alloc] initWithRootObjectClass:TMLoopTestAlpha.class];
    
    TMLoopTestAlpha *obj = [[TMLoopTestAlpha alloc] init];
    NSError* e = [xmlSerializer deserialize:[testXML dataUsingEncoding:NSUTF8StringEncoding] intoObject:obj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    STAssertNotNil(obj.bravo, @"Bravo should be parsed.");
    STAssertNotNil(obj.bravo.alpha, @"Inner alpha should be parsed.");
    STAssertEqualObjects(obj.bravo.alpha.test_str, @"hahaha", @"Inner object string deserialization failed.");
    STAssertEqualObjects(obj.test_str, @"wowowo", @"Outer object string deserialization failed.");
}

- (void)testCDATADeserialization
{
    static NSString* testXML = 
    @"<root><test_str1><![CDATA[function matchwo(a,b){if (a < b && a < 0) {return 1;}]]></test_str1></root>";
    TMXMLSerializer *xmlSerializer = [[TMXMLSerializer alloc] initWithRootObjectClass:TMSerializableTestSubObject.class];
    
    TMSerializableTestSubObject *obj = [[TMSerializableTestSubObject alloc] init];
    NSError* e = [xmlSerializer deserialize:[testXML dataUsingEncoding:NSUTF8StringEncoding] intoObject:obj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    STAssertEqualObjects(@"function matchwo(a,b){if (a < b && a < 0) {return 1;}", obj.test_str1, @"test str 1 failed.");
}

- (void)testReservedKeywords
{
    
}

#pragma mark -
#pragma mark Serialization
- (void)testStringObjectSerialization
{
    static NSString* testXML = 
    @"<TMSerializableTestSubObject><test_str1>TEST_STRING 123</test_str1></TMSerializableTestSubObject>";
    TMXMLSerializer *xmlSerializer = [[TMXMLSerializer alloc] initWithRootObjectClass:TMSerializableTestSubObject.class];
    
    TMSerializableTestSubObject *obj = [[TMSerializableTestSubObject alloc] init];
    NSError* e = [xmlSerializer deserialize:[testXML dataUsingEncoding:NSUTF8StringEncoding] intoObject:obj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    NSData *data = [xmlSerializer serialize:obj];
    TMSerializableTestSubObject *targetObj = [[TMSerializableTestSubObject alloc] init];
    e = [xmlSerializer deserialize:data intoObject:targetObj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    
    [self compare:targetObj withTarget:obj];
}

- (void)testComplexStringObjectSerialization
{
    static NSString* testXML =
    @"<TMSerializableTestSubObject><test_str1>Aoyama-itch ōme Station</test_str1></TMSerializableTestSubObject>";
    TMXMLSerializer *xmlSerializer = [[TMXMLSerializer alloc] initWithRootObjectClass:TMSerializableTestSubObject.class];
    
    TMSerializableTestSubObject *obj = [[TMSerializableTestSubObject alloc] init];
    NSError* e = [xmlSerializer deserialize:[testXML dataUsingEncoding:NSUTF8StringEncoding] intoObject:obj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    NSData *data = [xmlSerializer serialize:obj];
    TMSerializableTestSubObject *targetObj = [[TMSerializableTestSubObject alloc] init];
    e = [xmlSerializer deserialize:data intoObject:targetObj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    
    [self compare:targetObj withTarget:obj];
}

- (void)testMultiTypeSerialization
{
    static NSString* testXML = 
    @"<TMSerializableTestObject><test_integer>-789</test_integer><test_uinteger>123</test_uinteger><test_list_string>789str</test_list_string><test_list_string>str123</test_list_string><test_list_interger>789</test_list_interger><test_list_interger>123</test_list_interger><test_list_sub_object><test_str1>789str</test_str1></test_list_sub_object><test_list_sub_object><test_str2>str123</test_str2></test_list_sub_object><test_sub_object><test_str1>789str</test_str1></test_sub_object><test_date>Fri Aug 10  16:50:33 +0800 2012</test_date><test_float>456.5000</test_float><test_bool>true</test_bool></TMSerializableTestObject>";
    TMXMLSerializer *xmlSerializer = [[TMXMLSerializer alloc] initWithRootObjectClass:TMSerializableTestObject.class];
    
    TMSerializableTestObject *obj = [[TMSerializableTestObject alloc] init];
    NSError* e = [xmlSerializer deserialize:[testXML dataUsingEncoding:NSUTF8StringEncoding] intoObject:obj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    
    NSData *data = [xmlSerializer serialize:obj];
    TMSerializableTestObject *targetObj = [[TMSerializableTestObject alloc] init];
    e = [xmlSerializer deserialize:data intoObject:targetObj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    
    [self compare:targetObj withTarget:obj];
//    STAssertEqualObjects(target, testXML, @"test str failed.");
}

- (void)testLoopSubObjectSerialization
{
    static NSString* testXML = 
    @"<TMLoopTestAlpha><bravo><alpha><test_str>hahaha</test_str></alpha></bravo><test_str>wowowo</test_str></TMLoopTestAlpha>";
    TMXMLSerializer *xmlSerializer = [[TMXMLSerializer alloc] initWithRootObjectClass:TMLoopTestAlpha.class];
    
    TMLoopTestAlpha *obj = [[TMLoopTestAlpha alloc] init];
    NSError* e = [xmlSerializer deserialize:[testXML dataUsingEncoding:NSUTF8StringEncoding] intoObject:obj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    NSData *data = [xmlSerializer serialize:obj];
//    NSString *target = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    TMLoopTestAlpha *targetObj = [[TMLoopTestAlpha alloc] init];
    e = [xmlSerializer deserialize:data intoObject:targetObj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    [self compare:targetObj withTarget:obj];
//    STAssertEqualObjects(target, testXML, @"test str failed.");
}

- (void)testEnumSerialization
{
    static NSString* testXML = 
    @"<TMSerializableTestSubObject><test_gender>2</test_gender></TMSerializableTestSubObject>";
    TMXMLSerializer *xmlSerializer = [[TMXMLSerializer alloc] initWithRootObjectClass:TMSerializableTestSubObject.class];
    
    TMSerializableTestSubObject *obj = [[TMSerializableTestSubObject alloc] init];
    NSError* e = [xmlSerializer deserialize:[testXML dataUsingEncoding:NSUTF8StringEncoding] intoObject:obj];
    if (e)
    {
        STFail(@"Deserialization error:%@", e.domain);
    }
    NSData *data = [xmlSerializer serialize:obj];
    NSString *target = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    STAssertEqualObjects(target, testXML, @"test str failed.");
}

// failures testing

@end
