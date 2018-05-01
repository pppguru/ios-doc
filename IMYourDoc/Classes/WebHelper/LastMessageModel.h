//
//  LastMessageModel.h
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/6/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "MTLModel.h"
#import "Mantle.h"
#import "UsersModel.h"
#import "StatusModel.h"

@interface LastMessageModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *attachmentUid;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, assign) BOOL currentUser;
@property (nonatomic, strong) StatusModel *delivery;
@property (nonatomic, assign) BOOL file;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *fileType;
@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, strong) UsersModel *sender;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *threadName;
@property (nonatomic, copy) NSDate *timestamp;
@property (nonatomic, copy) NSString *type;

@end