//
//  LoginRequestModel.h
//  IMYourDoc
//
//  Created by Nicholas Graff on 6/30/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "MTLModel.h"
#import "Mantle.h"

@interface LoginRequestModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *user_name;

@end