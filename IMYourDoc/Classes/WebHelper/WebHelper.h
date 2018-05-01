//
//  WebHelper.h
//  StagCarnival
//
//  Created by Sarvjeet on 08/01/15.
//  Copyright (c) 2015 Gourav. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "MBProgressHUD.h"



typedef enum : NSInteger
{
    ApiResponseStatus_Success = 1 ,
    ApiResponseStatus_NotFound = 404 ,
    ApiResponseStatus_UnableToProceed =300 ,
    ApiResponseStatus_DuplicatedNotAllowed = 500  ,
    ApiResponseStatus_SessionExpired = 600  ,
    ApiResponseStatus_LoginFailed = 700  ,
    ApiResponseStatus_SessionAlreadyExpired = 800
    
} ApiResponseStatus;




typedef void (^completionBlock) (BOOL succeeded, NSDictionary *resultdict);
typedef void (^failureBlock) (BOOL succeeded, NSDictionary *resultdict);

@protocol WebHelperDelegate <NSObject, NSURLConnectionDelegate>


- (void)didReceivedresponse: (NSDictionary *) responsedict;

- (void)didFailedWithError: (NSError *) error;


@end


@interface WebHelper : NSObject

{
    NSMutableData *responseData;
    
    MBProgressHUD* spinner;
    
        id obj;
}



@property (nonatomic, weak) id <WebHelperDelegate> WebHelperDelegate;

@property (nonatomic, assign) int tag;

@property(nonatomic,retain)NSDictionary * request;



+ (WebHelper *) sharedHelper;

- (void)sendRequest: (NSDictionary *)param tag:(int)tag delegate:(id<WebHelperDelegate>) delegate;


//CALLBACK BLOCK

-(void)assignSender:(id)sender;

- (void)servicesWebHelperWith:(NSDictionary*)dict
                 successBlock:(completionBlock)completionBlock
                 failureBlock:(failureBlock)failure;


@end
