//
//  NSDictionary+MessageBody.h
//  IMYourDoc
//
//  Created by OSX on 26/11/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (MessageBody)

@property (nonatomic,strong) NSString *messageID;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSString *timestamp;
@property (nonatomic,strong) NSString *to;
@property (nonatomic,strong) NSString *from;
@property (nonatomic,strong) NSString *file_type;
@property (nonatomic,strong) NSString *file_path;



@end
