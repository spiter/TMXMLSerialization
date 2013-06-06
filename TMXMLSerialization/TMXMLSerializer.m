//
//  TMXMLSerializer.m
//  FemaleSNS
//
//  Created by Li Feng on 12-8-18.
//  Copyright (c) 2013 Li Feng. All rights reserved.
//

#import "TMXMLSerializer.h"

#import "TMXMLParserDelegate.h"
#import "TMSerializableType.h"
#import "TMLog.h"
#import <objc/runtime.h>

@interface TMXMLSerializer () 

@end

@implementation TMXMLSerializer

@synthesize targetType = _targetType;


- (id)initWithRootObjectClass:(Class)class
{
    self = [super init];
    if (self)
    {
        self.targetType = [TMSerializableType typeWithClass:class];
        if (self.targetType == nil)
        {
            return nil;
        }
    }
    return self;
}

- (NSString *)serializePrimitiveValue:(id)object withType:(NSString *)typeString andKey:(NSString *)key
{
    NSString *content = @"";
//    SEL selector = NSSelectorFromString(key);
    if ([typeString isEqualToString:@"int"]) {
        if (key == nil) {
            content = [self serializeInteger:[(NSNumber *)object integerValue]];
        } else {
            content = [self serializeInteger:[[(NSObject *)object valueForKey:key] integerValue]];
        }
    }
    else if ([typeString isEqualToString:@"float"]) {
        if (key == nil) {
            content = [self serializeFloat:[(NSNumber *)object floatValue]];
        } else {
            content = [self serializeFloat:[[(NSObject *)object valueForKey:key] floatValue]];
        }
    }
    else if ([typeString isEqualToString:@"boolean"] || [typeString isEqualToString:@"BOOL"]) {
        if (key == nil) {
            content = [self serializeBOOL:[(NSNumber *)object boolValue]];
        } else {
            content = [self serializeBOOL:[[(NSObject *)object valueForKey:key] boolValue]];
        }
    }
    else if ([typeString isEqualToString:@"unsigned long"] || [typeString isEqualToString:@"NSUInteger"]) {
        if (key == nil) {
            content = [self serializeUnsignedInteger:[(NSNumber *)object unsignedIntegerValue]];
        } else {
            content = [self serializeUnsignedInteger:[[(NSObject *)object valueForKey:key] unsignedIntegerValue]];
        }
    } else if ([typeString isEqualToString:@"NSDate"]) {
        if (key == nil) {
            content = [self serializeDate:(NSDate *)object];
        } else {
            content = [self serializeDate:[(NSObject *)object valueForKey:key]];// performSelector:selector]];
        }
    } else {
        if (key == nil) {
            content = object;
        } else {
            content = [(NSObject *)object valueForKey:key];// performSelector:selector];
        }
    }
    return content;
}

- (BOOL)serializeTypeObject:(id<TMSerializable>)object withContainerName:(NSString *)container appendToString:(NSMutableString *)result
{
    TMSerializableType *type = [TMSerializableType typeWithClass:[object class]];
    if (container == nil) {
        container = [NSString stringWithCString:class_getName([object class]) encoding:NSUTF8StringEncoding];
    }
//    NSString *tagName = [NSString stringWithCString:class_getName([object class]) encoding:NSUTF8StringEncoding];
    NSUInteger loc = result.length;
    NSString *tag = @"";
    if ([object respondsToSelector:@selector(dataID)]) {
        tag = [NSString stringWithFormat:@"<%@ id=\"%@\">", container, [object performSelector:@selector(dataID)]];
    } else {
        tag = [NSString stringWithFormat:@"<%@>", container];
    }
    NSUInteger length = tag.length;
    [result appendString:tag];
    __block BOOL isHasContent = NO;
    [type.propertyTypes enumerateKeysAndObjectsUsingBlock:^(NSString *key, TMPropertyType *subType, BOOL* stop){
        SEL selector = NSSelectorFromString(key);
        if ([object respondsToSelector:selector]) {
            if (![key isEqualToString:@"dataID"]) {
                if ([subType isListProperty]) {
                    NSMutableArray *list = [(NSObject *)object valueForKey:key]; //performSelector:selector];
                    [list enumerateObjectsUsingBlock:^(id<TMSerializable> listObject, NSUInteger idx, BOOL *listStop) {
                        if (![listObject conformsToProtocol:@protocol(TMSerializable)]) {
                            NSString *content = [self serializePrimitiveValue:listObject withType:subType.propertyType.typeStr andKey:nil];
                            if (content != nil) {
                                isHasContent = YES;
                                [result appendString:[NSString stringWithFormat:@"<%@>%@</%@>", key, content, key]];
                            }
                        } else {
                            BOOL isSuccess = [self serializeTypeObject:listObject withContainerName:key appendToString:result];
                            if (!isHasContent) {
                                isHasContent = isSuccess;
                            }
                        }
                    }];
                } else if ([subType isEnumProperty]) {
                    NSString *content = nil;
                    if (key == nil) {
                        content = [self serializeInteger:[(NSNumber *)object integerValue]];
                    } else {
                        content = [self serializeInteger:[[(NSObject *)object valueForKey:key] integerValue]];
                    }
                    if (content != nil) {
                        isHasContent = YES;
                        [result appendString:[NSString stringWithFormat:@"<%@>%@</%@>", key, content, key]];
                    }
                } else if ([subType.propertyType isSerializableType]) {
                    id<TMSerializable> subObject = [(NSObject *)object valueForKey:key];//performSelector:selector];
                    BOOL isSuccess = [self serializeTypeObject:subObject withContainerName:key appendToString:result];
                    if (!isHasContent) {
                        isHasContent = isSuccess;
                    }
                } else {
                    NSString *content = [self serializePrimitiveValue:object withType:subType.propertyType.typeStr andKey:key];
                    if (content != nil) {
                        isHasContent = YES;
                        [result appendString:[NSString stringWithFormat:@"<%@>%@</%@>", key, content, key]];
                    }
                }
            }
        }
    }];
    if (!isHasContent) {
        [result deleteCharactersInRange:NSMakeRange(loc, length)];
    } else {
        [result appendString:[NSString stringWithFormat:@"</%@>", container]];
    }
    return isHasContent;
}

- (NSData*)serialize:(id<TMSerializable>)object
{
    return [self serialize:object withRootName:nil];
}

- (NSData*)serialize:(id<TMSerializable>)object withRootName:(NSString *)rootName
{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    [self serializeTypeObject:object withContainerName:rootName appendToString:resultString];
    NSData *data = [resultString dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

- (NSError*)deserialize:(NSData*)data intoObject:(id<TMSerializable>)target
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    TMXMLParserDelegate *delegate = [[TMXMLParserDelegate alloc] init];
    delegate.parser = self;
    delegate.target = target;
    parser.delegate = delegate;
    
    if ([parser parse])
    {
        return nil;
    }
    return [parser parserError];
}

+ (NSString*)setterName:(NSString*)propertyName
{
    return [NSString stringWithFormat:@"set%@%@:", [[propertyName substringToIndex:1] capitalizedString], [propertyName substringFromIndex:1]];
}

//- (void)addPrimitiveValue:(NSString*)value withValueType:(TMSerializableType*)valueType toList:(NSMutableArray*)list
//{
//    
//}

- (NSMutableArray*)findAndInitListByPropertyName:(NSString*)propertyName forTarget:(id<TMSerializable>)target
{
    SEL arrayGetter = NSSelectorFromString(propertyName);
    if ([target respondsToSelector:arrayGetter]) {
        NSMutableArray *list = [(NSObject *)target valueForKey:propertyName];// performSelector:arrayGetter];
        if (list == nil) {
            list = [NSMutableArray array];
            SEL arraySetter = NSSelectorFromString([TMXMLSerializer setterName:propertyName]);
            if ([target respondsToSelector:arraySetter])
            {
                [(NSObject *)target setValue:list forKey:propertyName];// performSelector:arraySetter withObject:list];
            }
            else {
                LogWarning(@"No arraySetter found. %@", NSStringFromSelector(arraySetter));
            }
        }
        return list;
    }
    else {
        LogWarning(@"No arrayGetter found. %@", NSStringFromSelector(arrayGetter));
    }
    return nil;
}

- (void)assignPrimitiveValue:(NSString*)value forTarget:(id<TMSerializable>)target withTargetType:(TMSerializableType*)targetType andValueType:(TMPropertyType*)valueType andPropertyName:(NSString*)propertyName
{
    if ([valueType isEnumProperty]) {
        NSObject<TMSerializable> *targetObj = target;
        NSInteger intV = [self deserializeInteger:value];
        void *buffer = &intV;
        SEL setter = NSSelectorFromString([TMXMLSerializer setterName:propertyName]);
        if ([target respondsToSelector:setter]) {
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[targetObj methodSignatureForSelector:setter]];
            [inv setSelector:setter];
            [inv setTarget:target];
            [inv setArgument:buffer atIndex:2]; //arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
            [inv invoke];
        }
        else {
            LogWarning(@"No setter found. %@", NSStringFromSelector(setter));
        }
    } else {
        NSArray *objectTypeArray = [NSArray arrayWithObjects:@"NSString", @"NSDate", nil];
        NSArray *basicTypeArray = [NSArray arrayWithObjects:@"int", @"float", @"boolean", @"BOOL", @"unsigned long", @"NSUInteger", nil];
        if ([objectTypeArray containsObject:valueType.propertyType.typeStr]) {
            id objectValue = nil;
            if ([valueType.propertyType.typeStr isEqualToString:@"NSString"])
            {
                NSString* strV = value;
                if (strV == nil) {
                    strV = @"";
                }
                objectValue = strV;
            }
            else if ([valueType.propertyType.typeStr isEqualToString:@"NSDate"]) {
                NSDate *dateV = [self deserializeDate:value];
                if (dateV == nil) {
                    dateV = [NSDate date];
                }
                objectValue = dateV;
            }
            
            if ([valueType isListProperty]) {
                NSMutableArray *list = [self findAndInitListByPropertyName:propertyName forTarget:target];
                if (list != nil) {
                    [list addObject:objectValue];
                }
            }
            else {
                SEL setter = NSSelectorFromString([TMXMLSerializer setterName:propertyName]);        
                if ([target respondsToSelector:setter]) {
                    [(NSObject *)target setValue:objectValue forKey:propertyName];// performSelector:setter withObject:objectValue];
                }
                else {
                    LogWarning(@"No setter found. %@", NSStringFromSelector(setter));
                }
            }
        }
        else if ([basicTypeArray containsObject:valueType.propertyType.typeStr]) {
            NSObject<TMSerializable> *targetObj = target;
            NSNumber *number = nil;
            void *buffer = nil;
            if ([valueType.propertyType.typeStr isEqualToString:@"int"]) {
                NSInteger intV = [self deserializeInteger:value];
                number = [NSNumber numberWithInt:intV];
                buffer = &intV;
                
            }
            else if ([valueType.propertyType.typeStr isEqualToString:@"float"]) {
                float floatV = [self deserializeFloat:value];
                number = [NSNumber numberWithFloat:floatV];
                buffer = &floatV;
            }
            else if ([valueType.propertyType.typeStr isEqualToString:@"boolean"] || [valueType.propertyType.typeStr isEqualToString:@"BOOL"]) {
                BOOL boolV = [self deserializeBOOL:value];
                number = [NSNumber numberWithBool:boolV];
                buffer = &boolV;
            }
            else if ([valueType.propertyType.typeStr isEqualToString:@"unsigned long"] || [valueType.propertyType.typeStr isEqualToString:@"NSUInteger"]) {
                NSUInteger uintV = [self deserializeUnsignedInteger:value];
                number = [NSNumber numberWithUnsignedLong:uintV];
                buffer = &uintV;
            }
            
            if ([valueType isListProperty]) {
                NSMutableArray *list = [self findAndInitListByPropertyName:propertyName forTarget:target];
                if (list != nil) {
                    [list addObject:number];
                }
            }
            else {
                SEL setter = NSSelectorFromString([TMXMLSerializer setterName:propertyName]);
                if ([target respondsToSelector:setter]) {
                    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[targetObj methodSignatureForSelector:setter]];
                    [inv setSelector:setter];
                    [inv setTarget:target];
                    [inv setArgument:buffer atIndex:2]; //arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
                    [inv invoke];
                }
                else {
                    LogWarning(@"No setter found. %@", NSStringFromSelector(setter));
                }
            }
            
        }
        else {
            LogWarning(@"Unknown primitive type. %@", valueType.propertyType.typeStr);
        }
    }
}

- (void)assignSubObject:(id<TMSerializable>)subObj forTarget:(id<TMSerializable>)target withTargetType:(TMSerializableType*)targetType andValueType:(TMPropertyType*)valueType andPropertyName:(NSString*)propertyName
{
    NSObject<TMSerializable> *targetObj = target;
    if ([valueType isListProperty]) {
        NSMutableArray *list = [self findAndInitListByPropertyName:propertyName forTarget:target];
        if (list != nil) {
            [list addObject:subObj];
        }
    }
    else {
        SEL setter = NSSelectorFromString([TMXMLSerializer setterName:propertyName]);
        if ([targetObj respondsToSelector:setter]) {
            [(NSObject *)targetObj setValue:subObj forKey:propertyName];// performSelector:setter withObject:subObj];
        }
        else {
            LogWarning(@"No setter found. %@", NSStringFromSelector(setter));
        }
    }
}

- (NSInteger)deserializeInteger:(NSString*)data
{
    return [data integerValue];
}

- (NSString *)serializeInteger:(NSInteger)data
{
    return [NSString stringWithFormat:@"%d", data];
}

- (NSUInteger)deserializeUnsignedInteger:(NSString*)data
{
    return (NSUInteger)[data integerValue];
}

- (NSString *)serializeUnsignedInteger:(NSUInteger)data
{
    return [NSString stringWithFormat:@"%d", data];
}

- (float)deserializeFloat:(NSString*)data
{
    return [data floatValue];
}

- (NSString *)serializeFloat:(float)data
{
    return [NSString stringWithFormat:@"%.4f", data];
}

- (NSDateFormatter *)getTMDateFormatter
{
    NSString *formatter = @"EEE MMM dd  HH:mm:ss Z yyyy";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    NSTimeZone *tz = [NSTimeZone timeZoneWithAbbreviation:@"GMT+8"];
    [dateFormatter setTimeZone:tz];
    // have to set locale here to work in device, otherwies the result will be null
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    return dateFormatter;
}

- (NSDate*)deserializeDate:(NSString*)data
{
    return [[self getTMDateFormatter] dateFromString:data];
}

- (NSString *)serializeDate:(NSDate *)data
{
    return [[self getTMDateFormatter] stringFromDate:data];
}

- (BOOL)deserializeBOOL:(NSString*)data
{
    BOOL result = NO;
    if ([@"true" caseInsensitiveCompare:data] == NSOrderedSame) {
        result = YES;
    }
    return result;
}

- (NSString *)serializeBOOL:(BOOL)data
{
    if (data) {
        return @"true";
    } else {
        return @"false";
    }
}

@end
