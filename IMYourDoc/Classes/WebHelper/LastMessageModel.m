//
//  LastMessageModel.m
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/6/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "LastMessageModel.h"

@implementation LastMessageModel

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //Roll back to the previous version of timestamp in the server
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss Z";
    
    //This is for new timestamp format with miliseconds
//    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS Z";
    
    return dateFormatter;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"attachmentUid": @"attachmentUid",
             @"contentType": @"contentType",
             @"currentUser": @"currentUser",
             @"delivery": @"delivery",
             @"file": @"file",
             @"fileName": @"fileName",
             @"filePath": @"filePath",
             @"fileType": @"fileType",
             @"messageId": @"messageId",
             @"sender": @"sender",
             @"text": @"text",
             @"threadName": @"threadName",
             @"timestamp": @"timestamp",
             @"type": @"type"
             };
}

#pragma mark - JSON Transformers

+ (NSValueTransformer *)timestampJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error)
    {
        return [self.dateFormatter dateFromString:dateString];
    }
                                                reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error)
    {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (NSValueTransformer *)deliveryJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:StatusModel.class];
}

+ (NSValueTransformer *)senderJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:UsersModel.class];
}

@end
