//
//  HospitalModel.m
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/5/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "HospitalModel.h"

@implementation HospitalModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"city": @"city",
             @"creatorPhoneNumber": @"creatorPhoneNumber",
             @"id": @"id",
             @"name": @"name",
             @"primary": @"primary"
             };
}

@end