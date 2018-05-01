//
//  UsersModel.m
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/6/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "UsersModel.h"

@implementation UsersModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"admin": @"admin",
             @"banned": @"banned",
             @"member": @"member",
             @"username": @"username"
             };
}

@end
