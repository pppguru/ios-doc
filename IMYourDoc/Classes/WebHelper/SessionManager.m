//
//  SessionManager.m
//  IMYourDoc
//
//  Created by Nicholas Graff on 6/30/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "SessionManager.h"


@implementation SessionManager

- (id)init
{
    self = [super initWithBaseURL:[NSURL URLWithString:APISERVER]];
    if(!self)
        return nil;
    
    return self;
}

+ (id)sharedHTTPManager
{
    static SessionManager *_sessionManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sessionManager = [[self alloc] init];
        
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    
    return _sessionManager;
}

+ (id)sharedJSONManager
{
    static SessionManager *_sessionManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sessionManager = [[self alloc] init];
        
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    });
    
    return _sessionManager;
}

+ (id)sharedFileManager
{
    static SessionManager *_sessionManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sessionManager = [[self alloc] init];
        
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    
    return _sessionManager;
}



@end
