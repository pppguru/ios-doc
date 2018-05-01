//
//  StatusModel.m
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/12/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "StatusModel.h"

@implementation StatusModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"emailed": @"EMAILED",
             @"delivered": @"DELIVERED",
             @"acknowledged": @"ACKNOWLEDGED",
             @"notified": @"NOTIFIED",
             @"displayed": @"DISPLAYED"
             };
}

#pragma mark - JSON Transformers

+ (NSValueTransformer *)emailedJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:StatInfoModel.class];
}

+ (NSValueTransformer *)deliveredJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:StatInfoModel.class];
}

+ (NSValueTransformer *)acknowledgedJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:StatInfoModel.class];
}

+ (NSValueTransformer *)notifiedJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:StatInfoModel.class];
}

+ (NSValueTransformer *)displayedJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:StatInfoModel.class];
}

@end
