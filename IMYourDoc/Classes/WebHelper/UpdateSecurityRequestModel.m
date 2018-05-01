//
//  LoginRequestModel.m
//  IMYourDoc
//
//  Created by Nicholas Graff on 6/30/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "UpdateSecurityRequestModel.h"

@implementation UpdateSecurityRequestModel

#pragma mark - Mantle JSONKeyPathsByPropertyKey

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"password": @"password",
             @"pin": @"pin",
             @"securityAnswer": @"securityAnswer",
             @"securityQuestion": @"securityQuestion"
             };
}

@end
