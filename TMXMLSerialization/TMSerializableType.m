//
//  TMSerializableType.m
//  FemaleSNS
//
//  Created by Li Feng on 12-8-21.
//  Copyright (c) 2013 Li Feng. All rights reserved.
//

#import "TMSerializableType.h"
#import "objc/runtime.h"

#import "NSObject+PerformSelectorARCSafe.h"
#import "TMSerializable.h"
#import "TMSerializer.h"

@implementation TMPropertyType

@synthesize propertyType = _propertyType;
@synthesize isListProperty = _isListProperty;
@synthesize isEnumProperty = _isEnumProperty;

- (id)initWithSerializableType:(TMSerializableType*)type andIsList:(BOOL)isList andIsEnum:(BOOL)isEnum
{
    self = [super init];
    if (self) {
        self.isListProperty = isList;
        self.propertyType = type;
        self.isEnumProperty = isEnum;
    }
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"propertyType:%@ ", self.propertyType];
}

@end


@interface TMSerializableTypeManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *nameToType;
+ (TMSerializableTypeManager*)sharedInstance;
- (TMSerializableType*)typeWithStr:(NSString*)typestr;
@end

@implementation TMSerializableTypeManager

@synthesize nameToType = _nameToType;

static TMSerializableTypeManager* _managerInstance = nil;

+ (TMSerializableTypeManager*)sharedInstance
{
    if (_managerInstance == nil)
    {
        @synchronized(self){
            if (_managerInstance == nil)
            {
                _managerInstance = [[TMSerializableTypeManager alloc] init];
            }
        }
    }
    return _managerInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.nameToType = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (TMSerializableType*)typeWithStr:(NSString*)typestr
{
    return [self.nameToType objectForKey:typestr];
}

- (void)setType:(TMSerializableType*)type withStr:(NSString*)typestr
{
    return [self.nameToType setObject:type forKey:typestr];
}

@end


@implementation TMSerializableType

@synthesize typeStr = _typeStr;
@synthesize typeClass = _typeClass;
@synthesize propertyTypes = _propertyTypes;


#define primitiveTypes \
@"NSInteger", @"CGFloat", @"int", @"float", @"NSString", @"NSDate", @"BOOL", @"NSUInteger"
// more type like "NSDate", "NSData", "BOOL", "NSUInteger", "NSDouble", "double", "longlong"
#define normalizedPrimitiveTypes \
@"int", @"float", @"int", @"float", @"NSString", @"NSDate", @"boolean", @"unsigned long"

- (NSString*)description
{
    return [NSString stringWithFormat:@"\ntypeStr:%@, typeClass:%@, propertyTypes:%@", self.typeStr, NSStringFromClass(self.typeClass), self.propertyTypes];
}

static NSDictionary *_primitiveTypeNormalization = nil;

+ (NSDictionary*)primitiveTypeNormalization
{
    if (_primitiveTypeNormalization == nil)
    {
        @synchronized(TMSerializableType.class){
            if (_primitiveTypeNormalization == nil)
            {
                NSArray *priTypes = [NSArray arrayWithObjects:primitiveTypes, nil];
                NSArray *norTypes = [NSArray arrayWithObjects:normalizedPrimitiveTypes, nil];
                _primitiveTypeNormalization = [NSDictionary dictionaryWithObjects:norTypes forKeys:priTypes];
            }
        }
    }
    return _primitiveTypeNormalization;
}

+ (BOOL)isSupportedPrimitiveType:(NSString*)typeStr
{
    NSArray *allValues = [[TMSerializableType primitiveTypeNormalization] allValues];
    for (NSString *value in allValues) {
        if ([value isEqualToString:typeStr]) {
            return YES;
        }
    }
    return NO;
//    return [[TMSerializableType primitiveTypeNormalization] objectForKey:typeStr] != nil;
}

+ (BOOL)isSerializableType:(NSString *)typeStr
{
    const char *cTypeStr = [typeStr cStringUsingEncoding:NSUTF8StringEncoding];
    Class c = objc_lookUpClass(cTypeStr);
    if (c == nil)
    {
        return NO;
    }
    if ([c conformsToProtocol:@protocol(TMSerializable)]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isSupportedType:(NSString*)typeStr
{
    return [TMSerializableType isSupportedPrimitiveType:typeStr] || [TMSerializableType isSerializableType:typeStr];
}

+ (NSDictionary*)propertyTypes:(Class)class
{
    NSString *propertyPrefix = TM_SERIALIZABLE_PROPERTY_PREFIX_STRING;
    NSString *listPrefix = TM_SERIALIZABLE_LIST_PREFIX_STRING;
    NSString *enumPrefix = TM_SERIALIZABLE_ENUM_PREFIX_STRING;
    NSUInteger propertyPrefixLen = [propertyPrefix length];
    NSUInteger listPrefixLen = [listPrefix length];
    NSUInteger enumPrefixLen = [enumPrefix length];
    NSMutableDictionary *res = [NSMutableDictionary dictionary];
    unsigned int outCount = 0;
    NSObject *obj = [[class alloc] init];
    Method *methods = class_copyMethodList(class, &outCount);
    for (unsigned int i = 0; i < outCount; ++i) {
        SEL func = method_getName(*(methods + i));
        NSString *funcName = NSStringFromSelector(func);
        if ([funcName hasPrefix:propertyPrefix]) {
            NSString *possiblePropertyName = [funcName substringFromIndex:propertyPrefixLen];
            if ([possiblePropertyName length] != 0 && class_getProperty(class, [possiblePropertyName cStringUsingEncoding:NSUTF8StringEncoding]) != NULL) {
                NSString* type = [obj performSelectorSafe:func];
                TMSerializableType *t = [TMSerializableType typeWithStr:type];
                TMPropertyType *propertyType = [[TMPropertyType alloc] initWithSerializableType:t andIsList:NO andIsEnum:NO];
                [res setObject:propertyType forKey:possiblePropertyName];
            }
        }
        else if ([funcName hasPrefix:listPrefix])
        {
            NSString *possiblePropertyName = [funcName substringFromIndex:listPrefixLen];
            if ([possiblePropertyName length] != 0 && class_getProperty(class, [possiblePropertyName cStringUsingEncoding:NSUTF8StringEncoding]) != NULL) {
                NSString* type = [obj performSelectorSafe:func];
                TMSerializableType *t = [TMSerializableType typeWithStr:type];
                TMPropertyType *propertyType = [[TMPropertyType alloc] initWithSerializableType:t andIsList:YES andIsEnum:NO];
                [res setObject:propertyType forKey:possiblePropertyName];
            }
        }
        else if ([funcName hasPrefix:enumPrefix]) {
            NSString *possiblePropertyName = [funcName substringFromIndex:enumPrefixLen];
            if ([possiblePropertyName length] != 0 && class_getProperty(class, [possiblePropertyName cStringUsingEncoding:NSUTF8StringEncoding]) != NULL) {
                TMSerializableType *t = [TMSerializableType typeWithStr:@"NSInteger"];
                TMPropertyType *propertyType = [[TMPropertyType alloc] initWithSerializableType:t andIsList:NO andIsEnum:YES];
                [res setObject:propertyType forKey:possiblePropertyName];
            }
        }
    }
    free(methods);
    return res;
}

+ (NSString*)normalizedTypeStr:(NSString*)rawTypeStr
{
    NSString *trimmedString = [rawTypeStr stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmedString length] == 0)
    {
        return nil;
    }
    NSString *lastAlpha = [trimmedString substringFromIndex:[trimmedString length] - 1];
    if ([lastAlpha isEqualToString:@"*"]) {
        NSString *trimmedType = [[trimmedString substringToIndex:[trimmedString length] -1 ] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([trimmedType length] == 0) {
            return nil;
        }
        
        return trimmedType;
    }

    NSString *normedStr = [[TMSerializableType primitiveTypeNormalization] objectForKey:trimmedString];
    if (normedStr != nil) {
        return normedStr;
    }
    return trimmedString;
}

+ (TMSerializableType*)typeWithStr:(NSString*)typestr
{
    return [[TMSerializableType alloc] initWithTypeStr:typestr];
}

+ (TMSerializableType*)typeWithClass:(Class)class
{
    return [[TMSerializableType alloc] initWithClass:class];
}

- (id)initWithTypeStr:(NSString*)typeStr
{
    TMSerializableType *type = [[TMSerializableTypeManager sharedInstance]typeWithStr:typeStr];
    if (type != nil) {
        return type;
    }
    self = [super init];
    if (self)
    {
        [[TMSerializableTypeManager sharedInstance] setType:self withStr:typeStr];
        
        _typeStr = [TMSerializableType normalizedTypeStr:typeStr];
        if (_typeStr == nil) {
            return nil;
        }
        if ([TMSerializableType isSerializableType:self.typeStr]) {
            const char *cTypeStr = [self.typeStr cStringUsingEncoding:NSUTF8StringEncoding];
            _typeClass = objc_lookUpClass(cTypeStr);
        }
        else if ([TMSerializableType isSupportedPrimitiveType:self.typeStr]){
            _typeClass = nil;
        }
        else{
            return nil;
        }
        if (self.typeClass == nil) {
            _propertyTypes = nil;
        }
        else {
            _propertyTypes = [TMSerializableType propertyTypes:self.typeClass];
        }
    }
    return self;
}

- (id)initWithClass:(Class)class
{
    self = [super init];
    if (self)
    {
        if (![class conformsToProtocol:@protocol(TMSerializable)])
        {
            return nil;
        }
        _typeClass = class;
        _typeStr = NSStringFromClass(_typeClass);
        _propertyTypes = [TMSerializableType propertyTypes:self.typeClass];
    }
    return self;
}

- (BOOL)isPrimitiveType
{
    return self.typeClass == nil;
}

- (BOOL)isSerializableType
{
    return self.typeClass != nil;
}

@end
