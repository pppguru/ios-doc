//
//  UsersModel.h
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/6/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "MTLModel.h"
#import "Mantle.h"

@interface UsersModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) BOOL admin;
@property (nonatomic, assign) BOOL banned;
@property (nonatomic, assign) BOOL member;
@property (nonatomic, copy) NSString *username;

@end