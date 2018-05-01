//
//  SessionManager.h
//  IMYourDoc
//
//  Created by Nicholas Graff on 6/30/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "AFHTTPSessionManager.h"

#import "NilModel.h"
#import "UsersModel.h"
#import "FlagResponseModel.h"
#import "LoginRequestModel.h"
#import "RoomResponseModel.h"
#import "ErrorResponseModel.h"
#import "ThreadResponseModel.h"
#import "MessageResponseModel.h"
#import "ProfileResponseModel.h"
#import "UpdateSecurityRequestModel.h"

@interface SessionManager : AFHTTPSessionManager

+ (id)sharedHTTPManager;

+ (id)sharedJSONManager;

+ (id)sharedFileManager;


@end
