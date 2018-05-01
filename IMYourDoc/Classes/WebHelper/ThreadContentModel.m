//
//  ContentModel.m
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/6/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "ThreadContentModel.h"

@implementation ThreadContentModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"lastMessage": @"lastMessage",
             @"name": @"name",
             @"naturalName": @"naturalName",
             @"type": @"type",
             @"unreadCount": @"unreadCount",
             @"users": @"users"
             };
}

#pragma mark - JSON Transformers

+ (NSValueTransformer *)lastMessageJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:LastMessageModel.class];
}

+ (NSValueTransformer *)usersJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:UsersModel.class];
}

@end
