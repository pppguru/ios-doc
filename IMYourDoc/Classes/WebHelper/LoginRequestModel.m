//
//  LoginRequestModel.m
//  IMYourDoc
//
//  Created by Nicholas Graff on 6/30/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "LoginRequestModel.h"

@implementation LoginRequestModel

#pragma mark - Mantle JSONKeyPathsByPropertyKey

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"password": @"password",
             @"user_name": @"username"
             };
}

@end
