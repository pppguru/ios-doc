//
//  ActiveConverstion+ClassMethod.m
//  IMYourDoc
//
//  Created by OSX on 04/08/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "ActiveConverstion+ClassMethod.h"

@implementation ActiveConverstion (ClassMethod)

+(ActiveConverstion*)initWithJID:(NSString*)t_withjid  withLastActiveTime:(NSString *)t_LastactiveTime withLastActiveSec:(NSString*)t_last_active_sec     withContext:(NSManagedObjectContext*)context
{
  
    
        NSFetchRequest *alreadyExists = [[NSFetchRequest alloc] initWithEntityName:@"ActiveConverstion"];
        [alreadyExists  setPredicate:[NSPredicate predicateWithFormat:@"jid=%@AND str_lastActive=%@",t_withjid ,t_LastactiveTime ]];
        NSError *er = nil;
        NSArray *alreadyExistsArr = (NSArray*)[context executeFetchRequest:alreadyExists error:&er];
        
        if([alreadyExistsArr count]!=0)
        {
            return (ActiveConverstion*)[alreadyExistsArr firstObject];
        }
    
       else
       {
    ActiveConverstion *obj_ActiveConverstion    = [NSEntityDescription insertNewObjectForEntityForName:@"ActiveConverstion" inManagedObjectContext:context];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    //dateFormatter.dateFormat = @"yyyy-MM-ddThh:mm:ss.SSSZ";
           
    dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
          // 2015-07-01T07:11:48.328Z
    NSDate * obj_lastDatedate = [dateFormatter dateFromString: t_LastactiveTime];
    // NSDate * obj_lastdate = [dateFormatter dateFromString:t_lastdate]
    obj_ActiveConverstion.jid=t_withjid;
    obj_ActiveConverstion.lastActive=obj_lastDatedate;
    obj_ActiveConverstion.str_lastActive=t_LastactiveTime;
    obj_ActiveConverstion.str_last_active_sec=t_last_active_sec;
           
    return obj_ActiveConverstion;
    }
    
}

+(NSArray*) getAllObjectsWithContext:(NSManagedObjectContext*)context
{
    NSFetchRequest  *fetchReqConversationLog = [[NSFetchRequest alloc] init];
    
    fetchReqConversationLog.entity = [NSEntityDescription entityForName:@"ActiveConverstion" inManagedObjectContext:context];
    
    
    NSError *erConversationLog = nil;
    
    
    NSArray *allMsgsConversationLog = [context executeFetchRequest:fetchReqConversationLog error:&erConversationLog];
    return allMsgsConversationLog;
    
    
   
}

+(NSDate*)getStr_LastAciveDateOfJid:(NSString*)t_withjid withContext:(NSManagedObjectContext*)context
{
    if (t_withjid==nil) {
        return nil;
    }
    
    NSFetchRequest *alreadyExists = [[NSFetchRequest alloc] initWithEntityName:@"ActiveConverstion"];
    [alreadyExists  setPredicate:[NSPredicate predicateWithFormat:@"jid=%@ ",t_withjid  ]];
    NSError *er = nil;
    NSArray *alreadyExistsArr = (NSArray*)[context executeFetchRequest:alreadyExists error:&er];
    
    if([alreadyExistsArr count]!=0)
    {
        
        ActiveConverstion *obj= (ActiveConverstion*)[alreadyExistsArr firstObject];
        
        return obj.lastActive;
    }
    
    return nil;
    
}

@end
