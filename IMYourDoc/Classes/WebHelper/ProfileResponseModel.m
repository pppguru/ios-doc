//
//  profileResponseModel.m
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/1/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "ProfileResponseModel.h"

@class HospitalModel;
@class MiscModel;

@implementation ProfileResponseModel

#pragma mark - Mantle JSONKeyPathsByPropertyKey

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"deleted": @"deleted",
             @"designation": @"designation",
             @"email": @"email",
             @"firstName": @"firstName",
             @"hospitals": @"hospitals",
             @"inRoster": @"inRoster",
             @"jobTitle": @"jobTitle",
             @"lastName": @"lastName",
             @"loggedUser": @"loggedUser",
             @"name": @"name",
             @"phone": @"phone",
             @"photoUrl": @"photoUrl",
             @"practiceType": @"practiceType",
             @"userType": @"userType",
             @"username": @"username",
             @"zip": @"zip"
             };
}

#pragma mark - JSON Transformers

+ (NSValueTransformer *)hospitalsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:HospitalModel.class];
}

+ (NSValueTransformer *)designationJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:MiscModel.class];
}

+ (NSValueTransformer *)jobTitleJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:MiscModel.class];
}

+ (NSValueTransformer *)practiceTypeJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:MiscModel.class];
}

@end
