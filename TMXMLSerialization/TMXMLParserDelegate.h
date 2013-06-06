//
//  TMXMLParserDelegate.h
//  FemaleSNS
//
//  Created by  on 12-8-21.
//  Copyright (c) 2013 Li Feng. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMXMLSerializer;
@protocol TMSerializable;

@interface TMXMLParserDelegate : NSObject <NSXMLParserDelegate>

@property (nonatomic, unsafe_unretained) TMXMLSerializer *parser;
@property (nonatomic, strong) id<TMSerializable> target;

- (id)initWithParser:(TMXMLSerializer*)parser andTarget:(id<TMSerializable>)target;

@end
