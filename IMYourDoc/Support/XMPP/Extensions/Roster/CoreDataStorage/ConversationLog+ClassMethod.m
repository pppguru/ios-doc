//
//  ConversationLog+ClassMethod.m
//  IMYourDoc
//
//  Created by OSX on 24/07/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "ConversationLog+ClassMethod.h"
#import "AppDelegate.h"

@implementation ConversationLog (ClassMethod)
+(ConversationLog*)initMyJID:(NSString*)t_MYjid WithJID:(NSString*)t_withjid   lastSynDate:(NSString*)t_lastdate startDate:(NSString*)t_startdate withContext:(NSManagedObjectContext*)context
{
    ConversationLog *obj_conversation    = [NSEntityDescription insertNewObjectForEntityForName:@"ConversationLog" inManagedObjectContext:context];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    //[dateFormatter setDateFormat:@"yyyy-MM-ddTHH:mm:ss.SSSZ"];
     dateFormatter.dateFormat = @"yyyy-MM-ddThh:mm:ss.SSSZ";
    // dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss ";
    
   // dateFormatter.dateFormat = @"yyyy-MM-dd T hh:mm:ss Z";
    NSDate * obj_startdate = [dateFormatter dateFromString: t_startdate];
    // NSDate * obj_lastdate = [dateFormatter dateFromString:t_lastdate];
    
    
    
    NSDate *now = obj_startdate;
    NSDate *obj_lastdate =   [now dateByAddingTimeInterval:+1*24*60*60];
    
    obj_conversation.jid=t_MYjid;
    obj_conversation.withJid=t_withjid;
    obj_conversation.lastSynDate=obj_lastdate;
    obj_conversation.start=obj_startdate;
    obj_conversation.str_start=t_startdate;
    obj_conversation.read=[NSNumber numberWithBool:NO];
    return obj_conversation;
    
}
+(ConversationLog*)getIfObjectExistMyJID:(NSString*)t_MYjid WithJID:(NSString*)t_withjid   lastSynDate:(NSString*)t_lastdate startDate:(NSString*)t_startdate withContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *alreadyExists = [[NSFetchRequest alloc] initWithEntityName:@"ConversationLog"];
    [alreadyExists setPredicate:[NSPredicate predicateWithFormat:@"jid=%@ AND withJid=%@ AND str_start contains[cd] %@ ", t_MYjid,t_withjid ,t_startdate ]];
    [alreadyExists setFetchLimit:1];
    
    if(![AppDel managedObjectContext_roster])
        return nil;
    
    NSError __block *er = nil;
    NSArray __block *results = nil;
    
    [[AppDel managedObjectContext_roster] performBlockAndWait:^{
        results =[(NSManagedObjectContext*)[AppDel managedObjectContext_roster] executeFetchRequest:alreadyExists error:&er] ;
        
        if (!results)
        {
            NSLog(@"Error fetching traps: %@", er.localizedDescription);
            NSLog(@"Reason: %@", er.localizedFailureReason);
            NSLog(@"Suggestion: %@", er.localizedRecoverySuggestion);
            abort();
        }
        
    }];
    
    if (er != nil)
        return nil;

    if (results && [results isKindOfClass:[NSArray class]] && results.count > 0)
        return (ConversationLog*)[results firstObject];

    return nil;
}


+(ConversationLog*)getLastConversationMYJiD:(NSString*)jid WithJID:(NSString*)withjid withContext:(NSManagedObjectContext*)context
{
    
    ConversationLog * last_messages=nil;
    
    NSFetchRequest * request=[NSFetchRequest fetchRequestWithEntityName:@"ConversationLog"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"jid=%@AND withJid=%@ AND   read=%@",jid,withjid,[NSNumber numberWithBool:NO]]];
    
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"str_start" ascending:YES]];
    
    NSArray * last_chat = [[ AppDel managedObjectContext_roster] executeFetchRequest:request error:nil];
    
    last_messages = [last_chat lastObject];
    
    
    return last_messages;
    
    
    
}

+(void)resetConversationLogMYJiD:(NSString*)jid WithJID:(NSString*)withjid withContext:(NSManagedObjectContext*)context
{
    [context lock];
    NSFetchRequest * request=[NSFetchRequest fetchRequestWithEntityName:@"ConversationLog"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"jid=%@ AND withJid=%@ AND   read=%@",jid,withjid,[NSNumber numberWithBool:YES]]];
    NSError *er2 = nil;
    
    NSArray * last_chat = [context executeFetchRequest:request error:&er2];
    for (  ConversationLog * last_messages in last_chat)
    {
        last_messages.read=[NSNumber numberWithBool:NO];
    }
       NSError *er = nil;
          [context unlock];
       [context save:&er];
  
}

+(NSUInteger)getUnreadCountConversationLogMYJiD:(NSString*)jid WithJID:(NSString*)withjid withContext:(NSManagedObjectContext*)context{
    NSFetchRequest * request=[NSFetchRequest fetchRequestWithEntityName:@"ConversationLog"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"jid=%@ AND withJid=%@ AND read=%@",jid,withjid,[NSNumber numberWithBool:NO]]];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"str_start" ascending:YES]];
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:request error:&error];
    
    if (count != NSNotFound)
        return 0;
    else
        return count;
    
}

+(void) deleteAllObjectsWithContext:(NSManagedObjectContext*)context inTable:(NSString*)table;{
    NSFetchRequest  *fetchReqConversationLog = [[NSFetchRequest alloc] init];
    
    fetchReqConversationLog.entity = [NSEntityDescription entityForName:table inManagedObjectContext:context];
    NSError *erConversationLog = nil;
    NSArray *allMsgsConversationLog = [[AppDel managedObjectContext_roster] executeFetchRequest:fetchReqConversationLog error:&erConversationLog];
    for (NSManagedObject *msg in allMsgsConversationLog)
    {
        [context deleteObject:msg];
    }
}

@end
