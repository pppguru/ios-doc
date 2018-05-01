//
//  RoomResponseModel.m
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/6/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "RoomResponseModel.h"

@implementation RoomResponseModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"descriptions": @"description",
             @"name": @"name",
             @"naturalName": @"naturalName",
             @"users": @"users"
             };
}

#pragma mark - JSON Transformers

+ (NSValueTransformer *)usersJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:UsersModel.class];
}

@end
