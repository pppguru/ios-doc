//
//  APIManager.h
//  IMYourDoc
//
//  Created by Nicholas Graff on 6/30/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "SessionManager.h"

@interface APIManager : SessionManager

- (NSURLSessionDataTask *)loginWithRequestModel:(LoginRequestModel *)requestModel
                                        success:(void (^)())success
                                        failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)refreshTokenWithRequestModel:(LoginRequestModel *)requestModel
                                               success:(void (^)())success
                                               failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)profileRequest:(void (^)(ProfileResponseModel *))success
                                 failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)roomsRequest:(void (^)(NSArray<RoomResponseModel *> *))success
                               failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)roomMessagesRequest:(NSString *)roomName
                              beforeMessageID:(NSString *)beforeMessageID
                                      success:(void (^)(MessageResponseModel *))success
                                      failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)threadRequest:(void (^)(ThreadResponseModel *))success
                                failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)oneToOneMessagesRequest:(NSString *)userName
                                  beforeMessageID:(NSString *)beforeMessageID
                                          success:(void (^)(MessageResponseModel *))success
                                          failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)flagsRequest:(void (^)(NSArray<FlagResponseModel *> *))success
                               failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)contactsRequest:(void (^)(NSArray<ProfileResponseModel *> *))success
                                  failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)contactPhotosRequest:(NSString *)pathPart
                                       success:(void (^)(UIImage *))success
                                       failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)updateSecurityRequest:(UpdateSecurityRequestModel *)requestModel
                                        success:(void (^)(id response))success
                                        failure:(void (^)(NSError *error))failure;

@end
