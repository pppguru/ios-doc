//
//  InboxMessage+ClassMethods.m
//  IMYourDoc
//
//  Created by OSX on 10/12/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "InboxMessage+ClassMethods.h"
#import "AppDelegate.h"
@implementation InboxMessage (ClassMethods)

+(void)changeLastUpdateForInboxMessages
{
    
    
    
    NSFetchRequest * request=[NSFetchRequest fetchRequestWithEntityName:@"InboxMessage"];
    
 
 
    
    NSArray * last_chat = [[AppDel managedObjectContext_roster] executeFetchRequest:request error:nil];
 
    NSLog(@"Desc %@",last_chat);
    
    if (last_chat.count>0) {
        for (InboxMessage * inbox in last_chat)
        {
            
//           reqwest.predicate=[NSPredicate predicateWithFormat:@" uri = %@ and content!=%@ ",inbox.jidStr,[NSString stringWithFormat:@"~$^^xxx*xxx~$^^"]] ;
//            
            NSFetchRequest * reqwest=[NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
            reqwest.predicate=[NSPredicate predicateWithFormat:@" uri = %@ and content!=%@  and mark_deleted == 0  ",inbox.jidStr,[NSString stringWithFormat:@"~$^^xxx*xxx~$^^"]] ;
            reqwest.sortDescriptors=@[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES]];
            
    
            NSArray * arr_messages = [[AppDel managedObjectContext_roster] executeFetchRequest:reqwest error:nil];
            
            if (arr_messages.count>0)
            
            {
                
                ChatMessage * message=[arr_messages lastObject];
                
                if (message)
                    
                {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
                    
                    NSString *newDateString = [dateFormatter stringFromDate:message.timeStamp];;
                   
                    
                    NSDate *date = [dateFormatter dateFromString:newDateString];
                    
                  
                  
                    
                    inbox.lastUpdated=date;
                    [[AppDel managedObjectContext_roster] save:nil];
                }
              
                
                
            }

           
        }
    }
   
    
    
}
@end
