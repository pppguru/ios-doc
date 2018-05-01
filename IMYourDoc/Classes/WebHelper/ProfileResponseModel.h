//
//  profileResponseModel.h
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/1/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "MTLModel.h"
#import "Mantle.h"
#import "HospitalModel.h"
#import "MiscModel.h"

@interface ProfileResponseModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) BOOL deleted;
@property (nonatomic, strong) MiscModel *designation;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSArray<HospitalModel *> *hospitals;
@property (nonatomic, assign) BOOL inRoster;
@property (nonatomic, strong) MiscModel *jobTitle;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, assign) BOOL loggedUser;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *photoUrl;
@property (nonatomic, strong) MiscModel *practiceType;
@property (nonatomic, copy) NSString *userType;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *zip;

@end