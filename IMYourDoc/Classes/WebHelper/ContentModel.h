//
//  ContentModel.h
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/6/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "MTLModel.h"
#import "Mantle.h"
#import "LastMessageModel.h"

@interface ContentModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) LastMessageModel *lastMessage;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSNumber *unreadCount;
@property (nonatomic, copy) NSArray<UsersModel *> *users;

@end