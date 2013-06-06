//
//  TMXMLParserDelegate.m
//  FemaleSNS
//
//  Created by  on 12-8-21.
//  Copyright (c) 2013 Li Feng. All rights reserved.
//

#import "TMXMLParserDelegate.h"
#import "TMXMLSerializer.h"
#import "TMSerializableType.h"
#import "TMLog.h"

@interface TMParsingTarget : NSObject

@property (nonatomic, strong) TMPropertyType *type;
@property (nonatomic, strong) id<TMSerializable> obj;
@property (nonatomic, copy) NSString* elementName;
@property (nonatomic, copy) NSString* characters;

@end

@implementation TMParsingTarget

@synthesize type = _type;
@synthesize obj = _obj;
@synthesize elementName = _elementName;
@synthesize characters = _characters;


@end


@interface TMXMLParserDelegate ()

@property (nonatomic, strong) NSMutableArray *objStack;
@property (nonatomic, strong) NSMutableString *currentString;

@end

@implementation TMXMLParserDelegate

@synthesize parser = _parser;
@synthesize target = _target;
@synthesize objStack = _objStack;
@synthesize currentString = _currentString;


- (id)initWithParser:(TMXMLSerializer*)parser andTarget:(id<TMSerializable>)target
{
    self = [super init];
    if (self) {
        self.objStack = [NSMutableArray arrayWithCapacity:10];
        self.parser = parser;
        self.target = target;
        self.currentString = [[NSMutableString alloc] init];
    }
    return self;
}

- (id)init
{
    return [self initWithParser:nil andTarget:nil];
}

- (void)parseAttributes:(NSDictionary *)attributeDict
{
    [attributeDict enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* obj, BOOL *stop) {
        if ([key isEqualToString:@"id"]) {
            key = @"dataID";
        }
        if ([key isEqualToString:@"new"]) {
            key = @"dataNew";
        }
        TMPropertyType *valueType = [self.topTarget.type.propertyType.propertyTypes objectForKey:key];
        if (valueType != nil) {
            if ([valueType.propertyType isPrimitiveType]) {
                [self.parser assignPrimitiveValue:obj forTarget:self.topTarget.obj withTargetType:self.topTarget.type.propertyType andValueType:valueType andPropertyName:key];
            }
            else {
                LogWarning(@"attribute name found with a non primitive property.");
            }
        }
    }];
}

- (TMParsingTarget*)topTarget
{
    if ([self.objStack count] > 0)
    {
        return [self.objStack objectAtIndex:[self.objStack count] - 1];
    }
    return nil;
}

- (void)popTarget
{
    [self.objStack removeObjectAtIndex:[self.objStack count] - 1];
}

- (void)pushTarget:(TMParsingTarget*)target
{
    [self.objStack addObject:target];
}

- (void)pushTargetByObject:(id<TMSerializable>)obj andPropertyType:(TMPropertyType*)type andElementName:(NSString*)elementName
{
    TMParsingTarget *target = [[TMParsingTarget alloc] init];
    target.type = type;
    target.obj = obj;
    target.elementName = elementName;
    target.characters = nil;
    [self.objStack addObject:target];
}

#pragma mark - NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if (self.topTarget == nil)
    {
        TMPropertyType *propertyType = [[TMPropertyType alloc] initWithSerializableType:self.parser.targetType andIsList:NO andIsEnum:NO];
        [self pushTargetByObject:self.target andPropertyType:propertyType andElementName:elementName];
        [self parseAttributes:attributeDict];
        return;
    }

    id subType = [self.topTarget.type.propertyType.propertyTypes objectForKey:elementName];
    if (subType == nil) {
        // Not known element
        [self pushTargetByObject:nil andPropertyType:nil andElementName:elementName];
        return;
    }

    TMPropertyType *eleType = subType;
    if ([eleType.propertyType isSerializableType]) {
        id subObj = [[eleType.propertyType.typeClass alloc] init];
        [self pushTargetByObject:subObj andPropertyType:eleType andElementName:elementName];
        [self parseAttributes:attributeDict];
    }
    else {
        NSAssert([eleType.propertyType isPrimitiveType], @"Not a primitive type nor a serializable type.");
        [self pushTargetByObject:nil andPropertyType:eleType andElementName:elementName];
    }
    
    [self.currentString setString:@""];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (self.topTarget == nil)
    {
        LogWarning(@"characters without element found. %@", self.currentString);
        return;
    }
    if (self.topTarget.characters != nil)
    {
        LogWarning(@"Due characters in one element. %@ -AND- %@", self.topTarget.characters, self.currentString);
    }
    if (self.topTarget.type != nil && ![self.topTarget.type.propertyType isPrimitiveType])
    {
//        LogWarning(@"Characters found in non primitive element. %@ -AND- %@", self.topTarget.characters, self.currentString);
    }
    self.topTarget.characters = self.currentString;
    
    if (self.topTarget == nil)
    {
        LogWarning(@"Failed to find coresponding start element. %@", elementName);
        return;
    }
    
    if (![self.topTarget.elementName isEqualToString:elementName])
    {
        LogWarning(@"Coresponding start element not match. %@ -AND- %@", self.topTarget.elementName, elementName);
        return;
    }
    
    TMParsingTarget *target = self.topTarget;
    [self popTarget];
    if (self.topTarget == nil) {
        // root target finished.
        return;
    }
    if (target.type == nil) {
        // unrecognized element, not need to parse
        return;
    }
    
    if ([target.type.propertyType isPrimitiveType])
    {
        [self.parser assignPrimitiveValue:target.characters forTarget:self.topTarget.obj withTargetType:self.topTarget.type.propertyType andValueType:target.type andPropertyName:target.elementName];
    }
    else {
        NSAssert([target.type.propertyType isSerializableType], @"Not a primitive type nor a serializable type.");
        [self.parser assignSubObject:target.obj forTarget:self.topTarget.obj withTargetType:self.topTarget.type.propertyType andValueType:target.type andPropertyName:target.elementName];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [self.currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue
{
    LogDebug(@"...");
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (self.topTarget != nil)
    {
        LogWarning(@"element left in stack!.");
    }
}


@end

