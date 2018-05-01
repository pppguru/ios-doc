//
//  WebHelper.m
//  StagCarnival
//
//  Created by Sarvjeet on 08/01/15.
//  Copyright (c) 2015 Gourav. All rights reserved.
//


#import "WebHelper.h"
#import "AppDelegate+ClassMethods.h"

@implementation WebHelper


+ (WebHelper *) sharedHelper
{
    static WebHelper *sharedInstance = nil;
    
    if (sharedInstance == nil)
    {
        sharedInstance = [[WebHelper alloc] init];
        
    }
    
    return sharedInstance;
}
-(void)assignSender:(id)sender
{
    obj = sender;
}


#pragma mark - Request Call

- (void)sendRequest: (NSDictionary *)param tag:(int)tag delegate:(id<WebHelperDelegate>) delegate
{
    
    NSURL *url = [NSURL URLWithString:BASE_URL];
    
    NSError *error;
    ASIHTTPRequest *request2 = [ASIHTTPRequest requestWithURL:url];
    
    [request2 setRequestMethod:@"POST"];
    [request2 addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [request2 setValidatesSecureCertificate:NO];
    
    request2.postBody = [[NSJSONSerialization dataWithJSONObject:param
                                                         options:NSJSONWritingPrettyPrinted error:&error] mutableCopy];
    
    request2.timeOutSeconds=10;
    
    //This has been renamed to request3 (from request) to remove the naming conflict
    __weak ASIHTTPRequest * request3 = request2;
    
    [request2 setCompletionBlock:^
     {
         self.request=param;
         
         [AppDel writeLogInFileWithClassFunctionLine:[NSString stringWithFormat:@"%s %d",__PRETTY_FUNCTION__,__LINE__] operation:@"webService" Content:[NSString stringWithFormat:@"method %@ \t ",[param objectForKey:@"method"] ]parameter:@""];
         
         //Refactored 1000 lines of redundant code (if / else if / ...) that did exactly the same thing in each boolean case
         NSDictionary *response = [NSJSONSerialization JSONObjectWithData:request3.responseData options:NSJSONReadingMutableContainers error:nil];
         
         self.tag = tag;
         
         if ([self.WebHelperDelegate respondsToSelector:@selector(didReceivedresponse:)])
         {
             [self.WebHelperDelegate didReceivedresponse:response];
         }
     }];
    
    [request2 setFailedBlock:^
     {
         self.tag = tag;
         
         //Refactored the boolean logic to actually send to the delegate an appropriate error
         if( request3.error != nil ){
             [self.WebHelperDelegate didFailedWithError:request3.error];
             NSLog(@"Request Fail With Error: %@", request3.error);
         }
         else {
             [self.WebHelperDelegate didFailedWithError:[NSError  errorWithDomain:@"Unable to login" code:2 userInfo:@{NSLocalizedDescriptionKey:@"Unable to login"}]];
             NSLog(@"Unable to login");
         }
     }];
    
    [request2 startAsynchronous];
}

- (void)servicesWebHelperWith:(NSDictionary*)dict
                 successBlock:(completionBlock)completionBlock
                 failureBlock:(failureBlock)failure
{
    
    if ([AppDel appIsDisconnected]==YES || dict==nil)
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
            
            failure(YES,nil);
        });
        
        return;
    }
    
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        {
            
            NSURL *url = [NSURL URLWithString:BASE_URL];
            
            NSError *error;
            
            ASIHTTPRequest *request2 = [ASIHTTPRequest requestWithURL:url];
            
            
            [request2 setRequestMethod:@"POST"];
            
            [request2 addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
            
            [request2 setValidatesSecureCertificate:NO];
            
            // request2.timeOutSeconds=10;
            
            
            if(dict==nil )
            {
                return ;
            }
            
            if([NSJSONSerialization isValidJSONObject:dict])
            {
                
                NSMutableData *data =[[NSJSONSerialization dataWithJSONObject:dict
                                                                      options:NSJSONWritingPrettyPrinted error:&error] mutableCopy];
                
                
                if (data) {
                    request2.postBody = data;
                    __weak ASIHTTPRequest * request=request2;
                    
                    
                    if (error == nil)
                    {
                        [request2 setCompletionBlock:^
                         {
                             if (request) {
                                 
                                 
                                 if (request.responseData) {
                                     
                                     
                                     NSDictionary *response = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:nil];
                                     dispatch_async(dispatch_get_main_queue(),^
                                                    {
                                                        completionBlock(YES,response);
                                                        
                                                    } );
                                     
                                 }
                                 
                                 
                             }
                             
                         }];
                        
                        
                        [request2 setFailedBlock:^
                         {
                             if (request) {
                                 
                                 dispatch_async(dispatch_get_main_queue(),^
                                                {
                                                    failure(YES,nil);
                                                });
                             }
                         }];
                        
                        [request2 startAsynchronous];
                    }
                    else{
                        NSLog(@"Error %@",error.description);
                    }
                }
            }
            else{
                [[[UIAlertView alloc] initWithTitle:nil message:@"No valid Data" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }
        }
    });
}


#pragma mark - Request Responses

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
    
    
    if ([self.WebHelperDelegate respondsToSelector:@selector(didReceivedresponse:)])
    {
        [self.WebHelperDelegate didReceivedresponse:response];
    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([self.WebHelperDelegate respondsToSelector:@selector(didFailedWithError:)])
    {
        [self.WebHelperDelegate didFailedWithError:nil];
    }
}

@end
