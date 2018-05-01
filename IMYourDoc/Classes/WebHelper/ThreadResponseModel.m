//
//  MessageResponseModel.m
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/6/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "ThreadResponseModel.h"

@implementation ThreadResponseModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"content": @"content",
             @"first": @"first",
             @"last": @"last",
             @"number": @"number",
             @"numberOfElements": @"numberOfElements",
             @"size": @"size",
             @"sort": @"sort",
             @"totalElements": @"totalElements",
             @"totalPages": @"totalPages"
             };
}

#pragma mark - JSON Transformers

+ (NSValueTransformer *)contentJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:ThreadContentModel.class];
}

+ (NSValueTransformer *)sortJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:NilModel.class];
}

@end
