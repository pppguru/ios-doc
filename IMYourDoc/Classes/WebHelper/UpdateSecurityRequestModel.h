//
//  LoginRequestModel.h
//  IMYourDoc
//
//  Created by Nicholas Graff on 6/30/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "MTLModel.h"
#import "Mantle.h"

@interface UpdateSecurityRequestModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *pin;
@property (nonatomic, copy) NSString *securityAnswer;
@property (nonatomic, copy) NSString *securityQuestion;

@end