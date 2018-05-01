//
//  GroupChatReadbyList+ClassMethod.m
//  IMYourDoc
//
//  Created by OSX on 01/04/16.
//  Copyright (c) 2016 vijayvir . All rights reserved.
//

#import "GroupChatReadbyList+ClassMethod.h"
#import "AppDelegate.h"
@implementation GroupChatReadbyList (ClassMethod)


+(GroupChatReadbyList *)insertChatReadByMessage:(ChatMessage *)message userJID:(NSString *)userJID
{
    
    __block GroupChatReadbyList * readBy=nil;
  
    
        
        
        readBy =[NSEntityDescription insertNewObjectForEntityForName:@"GroupChatReadbyList" inManagedObjectContext:[AppDel managedObjectContext_roster]];
        
         readBy.userJID=userJID;
        
        [message addReadbyObject:readBy];
        

    
        
        
  
    return readBy;
    
}
@end
