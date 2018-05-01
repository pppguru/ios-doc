//
//  RoomResponseModel.h
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/6/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "MTLModel.h"
#import "Mantle.h"
#import "UsersModel.h"

@interface RoomResponseModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *descriptions;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *naturalName;
@property (nonatomic, strong) NSArray<UsersModel *> *users;

@end
