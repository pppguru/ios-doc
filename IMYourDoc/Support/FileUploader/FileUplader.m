//
//  FileUplader.m
//  IMYourDoc
//
//  Created by Manpreet on 08/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "FileUplader.h"
#import "XMPPJID.h"
#import "AppDelegate.h"
@implementation FileUplader

+(FileUplader*)createRequestWithChatMessage:(ChatMessage*)message WithManagedObjectContext:(NSManagedObjectContext*)context

{

          message.requestStatus = [NSNumber numberWithInt:RequestStatusType_uploading]; //uploading 
        [context save:nil];
        __block      FileUplader *fileUploader = [FileUplader requestWithURL:[NSURL URLWithString:URLBUILER(@"https://api.imyourdoc.com/serviceFiles.php") ]];
        
        fileUploader.message = message;
        
        [fileUploader setPostFormat:ASIMultipartFormDataPostFormat];
        
        [fileUploader addFile:[NSTemporaryDirectory() stringByAppendingPathComponent:message.content] withFileName:message.content andContentType:@"image/jpeg" forKey:@"upload"];
        
        [fileUploader addPostValue:@"uploadFile" forKey:@"method"];
        
        [fileUploader addPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"] forKey:@"login_token"];
        [fileUploader addPostValue:@"image" forKey:@"type"];
        
        [fileUploader addPostValue:[[XMPPJID jidWithString:message.uri] user] forKey:@"user_group_name"];
        
        [fileUploader setValidatesSecureCertificate:NO];
        
        [fileUploader setDelegate:AppDel];
        
        fileUploader.timeOutSeconds=60;
    
    
        fileUploader.tag = TAG_FILE_UPLOADER;
        
    fileUploader.name=message.messageID;
    
    

    
    for(FileUplader *temp in [AppDel fileQue])
    {
        if ([temp.name isEqualToString:fileUploader.name])
        {
        
            return nil;
        }
        
    }
    
    
        [[AppDel fileQue] addObject:fileUploader];
    
    
    if(TARGET_IPHONE_SIMULATOR)
    {
        
        
      
        
        @autoreleasepool {
              FileUplader *temp=[[AppDel fileQue]firstObject];
            (void)temp;
        }
        

        
    }

    
    
        message.recivedsize=0;
    
        [fileUploader setBytesSentBlock:^(unsigned long long size, unsigned long long total)
         {
             
             
             
             message.recivedsize=size+message.recivedsize;
             
             message.dataSent= [NSNumber numberWithLongLong:((message.recivedsize*100)/total)];
             
             
             
             [context save:nil];
             
             
         }];


        [fileUploader startAsynchronous];
    
    return fileUploader;
}
@end
