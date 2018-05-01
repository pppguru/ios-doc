//
//  FlagRequestModel.m
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/8/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "FlagResponseModel.h"

@implementation FlagResponseModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"flagType": @"flagType",
             @"value": @"value"
             };
}

@end
