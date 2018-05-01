//
//  ErrorResponseModel.m
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/12/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "ErrorResponseModel.h"

@implementation ErrorResponseModel

#pragma mark - Mantle JSONKeyPathsByPropertyKey

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"timestamp": @"timestamp",
             @"status": @"status",
             @"error": @"error",
             @"exception": @"exception",
             @"message": @"message",
             @"propagated": @"propagated"
             };
}

@end
