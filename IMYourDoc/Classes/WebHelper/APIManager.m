//
//  APIManager.m
//  IMYourDoc
//
//  Created by Nicholas Graff on 6/30/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "APIManager.h"
#import "Mantle.h"
#import "AppDelegate.h"



static NSString *const authPath = @"/imyd-auth-stateless-web";
static NSString *const restPath = @"/imyd-webchat-api";

@implementation APIManager

#pragma mark - Requests

- (NSURLSessionDataTask *)loginWithRequestModel:(LoginRequestModel *)requestModel
                                        success:(void (^)())success
                                        failure:(void (^)(NSError *error))failure
{
    //Double check for loginRequestModel
    if (requestModel == nil ||
        requestModel.user_name == nil || requestModel.user_name.length == 0 ||
        requestModel.password == nil || requestModel.password.length == 0) {
        
        failure(nil);
        return nil;
    }
    //Added by Ronald [10/25]
    
    if (![self.responseSerializer isMemberOfClass:[AFHTTPResponseSerializer class]]){
        failure(nil);
        return nil;
    }
    
    NSDictionary *parameters = [MTLJSONAdapter JSONDictionaryFromModel:requestModel error:nil];
    NSMutableDictionary *parametersWithKey = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    
    NSString *loginPath = [NSString stringWithFormat: @"%@/tokens/imUser/new", authPath];
    
    return [self POST:loginPath
           parameters:parametersWithKey
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
            {
                NSString *authToken;
                NSHTTPCookie *cookie;
                NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                
                for (cookie in [cookieJar cookies]) {
                    if ([cookie.name isEqual:@"x-auth-token"])
                        authToken = cookie.value;
                }
                
                //Apply the token and messsage size to all JSON requests
                [[AppData appData] setUserAccessToken:authToken];
                [[AppData appData] addAuthTokenIntoHeaderOfAPIManager:authToken withHeaderName:@"x-auth-token"];
                
                success();
            }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
            {
                failure(error);
            }];
}


- (NSURLSessionDataTask *)refreshTokenWithRequestModel:(LoginRequestModel *)requestModel
                                               success:(void (^)())success
                                               failure:(void (^)(NSError *error))failure
{
    //Double check for loginRequestModel
    if (requestModel == nil ||
        requestModel.user_name == nil || requestModel.user_name.length == 0 ||
        requestModel.password == nil || requestModel.password.length == 0) {
        
        failure(nil);
        return nil;
    }
    //Added by Ronald [10/25]
    
    if (![self.responseSerializer isMemberOfClass:[AFHTTPResponseSerializer class]]){
        failure(nil);
        return nil;
    }
    
    
    
    NSDictionary *parameters = [MTLJSONAdapter JSONDictionaryFromModel:requestModel error:nil];
    NSMutableDictionary *parametersWithKey = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    
    NSString *loginPath = [NSString stringWithFormat: @"%@/tokens/imUser/new", authPath];
    
    return [self POST:loginPath
           parameters:parametersWithKey
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
            {
                NSString *authToken;
                NSHTTPCookie *cookie;
                NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                
                for (cookie in [cookieJar cookies]) {
                    if ([cookie.name isEqual:@"x-auth-token"])
                        authToken = cookie.value;
                }
                
                //Apply the token and messsage size to all JSON requests
                [[AppData appData] setUserAccessToken:authToken];
                [[AppData appData] addAuthTokenIntoHeaderOfAPIManager:authToken withHeaderName:@"x-auth-token"];
                
                success();
            }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
            {
                failure(error);
            }];
}


- (NSURLSessionDataTask *)profileRequest:(void (^)(ProfileResponseModel *))success
                                 failure:(void (^)(NSError *error))failure
{
    NSString *path = [NSString stringWithFormat: @"%@/api/v1/profile/details", restPath];
    
    return [self GET:path
          parameters:nil
            progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
            {
                NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                
                NSError *error;
                ProfileResponseModel *list = [MTLJSONAdapter modelOfClass:ProfileResponseModel.class
                                                       fromJSONDictionary:responseDictionary
                                                                    error:&error];
                
                success(list);
            }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
            {
                failure(error);
            }];
}


- (NSURLSessionDataTask *)roomsRequest:(void (^)(NSArray<RoomResponseModel *> *))success
                               failure:(void (^)(NSError *error))failure
{
    NSString *path = [NSString stringWithFormat: @"%@/api/v1/rooms", restPath];
    
    return [self GET:path
          parameters:nil
            progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
            {
                NSArray *responseArray = (NSArray *)responseObject;
                NSMutableArray<RoomResponseModel *> *arrayList = [NSMutableArray<RoomResponseModel *> new];
                
                for (int i = 0; i < responseArray.count; i++)
                {
                    NSDictionary *responseDictionary = (NSDictionary *)responseArray[i];
                    
                    NSError *error;
                    RoomResponseModel *list = [MTLJSONAdapter modelOfClass:RoomResponseModel.class
                                                        fromJSONDictionary:responseDictionary
                                                                     error:&error];
                    [arrayList addObject:list];
                }
                
                success(arrayList);
            }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
            {
                failure(error);
            }];
}

- (NSURLSessionDataTask *)roomMessagesRequest:(NSString *)roomName
                              beforeMessageID:(NSString *)beforeMessageID
                                      success:(void (^)(MessageResponseModel *))success
                                      failure:(void (^)(NSError *error))failure
{
    NSString *path = [NSString stringWithFormat: @"%@/api/v1/communication/rooms/%@/messages", restPath, roomName];

    NSDictionary *parameters = nil;
    if (beforeMessageID && beforeMessageID.length > 0) {
        parameters = [NSDictionary dictionaryWithObject:beforeMessageID forKey:@"beforeMessageId"];
    }
    
    return [self GET:path
          parameters:parameters ? parameters : nil
            progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
            {
                NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                
                NSError *error;
                MessageResponseModel *list = [MTLJSONAdapter modelOfClass:MessageResponseModel.class
                                                       fromJSONDictionary:responseDictionary
                                                                    error:&error];
                
                success(list);
            }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
            {
                failure(error);
            }];
}

- (NSURLSessionDataTask *)threadRequest:(void (^)(ThreadResponseModel *))success
                                failure:(void (^)(NSError *error))failure
{
    NSString *page = [[NSUserDefaults standardUserDefaults] objectForKey:@"page"];
    NSString *page_size = INBOX_THREAD_PAGE_SIZE;
    
    NSString *path = [NSString stringWithFormat: @"%@/api/v1/communication/threads?page=%@&size=%@", restPath, page, page_size];
    
    return [self GET:path
          parameters:nil
            progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
            {
                int tmp = [page intValue];
                tmp++;
                
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", tmp] forKey:@"page"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                
                NSError *error;
                ThreadResponseModel *list = [MTLJSONAdapter modelOfClass:ThreadResponseModel.class
                                                      fromJSONDictionary:responseDictionary
                                                                   error:&error];
                
                success(list);
            }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
            {
                failure(error);
            }];
}

- (NSURLSessionDataTask *)oneToOneMessagesRequest:(NSString *)userName
                                  beforeMessageID:(NSString *)beforeMessageID
                                          success:(void (^)(MessageResponseModel *))success
                                          failure:(void (^)(NSError *error))failure
{
    NSString *path = [NSString stringWithFormat: @"%@/api/v1/communication/oneToOnes/%@/messages", restPath, userName];
    
    NSDictionary *parameters = nil;
    if (beforeMessageID && beforeMessageID.length > 0) {
        parameters = [NSDictionary dictionaryWithObject:beforeMessageID forKey:@"beforeMessageId"];
    }
    
    return [self GET:path
          parameters:parameters ? parameters : nil
            progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
            {
                NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                
                NSError *error;
                MessageResponseModel *list = [MTLJSONAdapter modelOfClass:MessageResponseModel.class
                                                       fromJSONDictionary:responseDictionary
                                                                    error:&error];
                
                success(list);
            }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
            {
                failure(error);
            }];
}

- (NSURLSessionDataTask *)flagsRequest:(void (^)(NSArray<FlagResponseModel *> *))success
                               failure:(void (^)(NSError *error))failure
{
    NSString *path = [NSString stringWithFormat: @"%@/api/v1/flags", restPath];
    
    return [self GET:path
          parameters:nil
            progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
            {
                NSArray *responseArray = (NSArray *)responseObject;
                NSMutableArray<FlagResponseModel *> *arrayList = [NSMutableArray<FlagResponseModel *> new];
                
                for (int i = 0; i < responseArray.count; i++)
                {
                    NSDictionary *responseDictionary = (NSDictionary *)responseArray[i];
                    
                    NSError *error;
                    FlagResponseModel *list = [MTLJSONAdapter modelOfClass:FlagResponseModel.class
                                                        fromJSONDictionary:responseDictionary
                                                                     error:&error];
                    [arrayList addObject:list];
                }
                
                success(arrayList);
            }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
            {
                failure(error);
            }];
}

- (NSURLSessionDataTask *)contactsRequest:(void (^)(NSArray<ProfileResponseModel *> *))success
                                  failure:(void (^)(NSError *error))failure
{
    NSString *path = [NSString stringWithFormat: @"%@/api/v1/contacts", restPath];
    
    return [self GET:path
          parameters:nil
            progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
            {
                NSArray *responseArray = (NSArray *)responseObject;
                NSMutableArray<ProfileResponseModel *> *arrayList = [NSMutableArray<ProfileResponseModel *> new];
                
                for (int i = 0; i < responseArray.count; i++)
                {
                    NSDictionary *responseDictionary = (NSDictionary *)responseArray[i];
                    
                    NSError *error;
                    ProfileResponseModel *list = [MTLJSONAdapter modelOfClass:ProfileResponseModel.class
                                                        fromJSONDictionary:responseDictionary
                                                                     error:&error];
                    [arrayList addObject:list];
                }
                
                success(arrayList);
            }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
            {
                failure(error);
            }];
}

- (NSURLSessionDataTask *)contactPhotosRequest:(NSString *)pathPart
                                       success:(void (^)(UIImage *))success
                                       failure:(void (^)(NSError *error))failure;
{
    
    if (![self.responseSerializer isMemberOfClass:[AFHTTPResponseSerializer class]]){
        failure(nil);
        return nil;
    }
    
    
    NSString *path = [NSString stringWithFormat: @"%@/api/v1/contacts/%@/photo", restPath, pathPart];
    
    return [self GET:path
          parameters:nil
            progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
            {
                UIImage *image;
                
                if (responseObject) {
                    image = [UIImage imageWithData:responseObject];
                    
                    success(image);
                }
                else{
                    failure(nil);
                }
                
                
            }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
            {
                failure(error);
            }];
}

- (NSURLSessionDataTask *)updateSecurityRequest:(UpdateSecurityRequestModel *)requestModel
                                        success:(void (^)(id response))success
                                        failure:(void (^)(NSError *error))failure
{
    
    NSString *path = [NSString stringWithFormat: @"%@/api/v1/profile/security", restPath];
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:requestModel.password forKey:@"password"];
    NSMutableDictionary *parametersWithKey = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    
    return [self PATCH:path
            parameters:parametersWithKey
               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
                {
                    success(responseObject);
                }
               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
                {
                    failure(error);
                }];
    
}

@end
