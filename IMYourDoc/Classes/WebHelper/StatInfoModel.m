//
//  StatInfoModel.m
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/12/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "StatInfoModel.h"

@implementation StatInfoModel

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss Z";
    return dateFormatter;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"username": @"username",
             @"date": @"date"
             };
}

#pragma mark - JSON Transformers

+ (NSValueTransformer *)dateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error)
            {
                return [self.dateFormatter dateFromString:dateString];
            }
                                                reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error)
            {
                return [self.dateFormatter stringFromDate:date];
            }];
}

@end
