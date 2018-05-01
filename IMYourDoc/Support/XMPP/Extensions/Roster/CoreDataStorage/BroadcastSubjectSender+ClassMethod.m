//
//  BroadcastSubjectSender+ClassMethod.m
//  IMYourDoc
//
//  Created by vijayveer on 23/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "BroadCastGroup.h"
#import "BroadcastSubjectSender+ClassMethod.h"
#import "AppDelegate.h"

@implementation BroadcastSubjectSender (ClassMethod)

- (void)removeMessages:(NSSet *)values
{
    
    for (id obj in values) {
        [[self managedObjectContext] deleteObject:obj];
    }
}

+(BroadcastSubjectSender*)initWithSubject:(NSString*)str_subject group:(BroadCastGroup *) group  {
    
    BroadcastSubjectSender* subject = [NSEntityDescription insertNewObjectForEntityForName:@"BroadcastSubjectSender" inManagedObjectContext:[AppDel managedObjectContext_roster]];
    
    subject.ofGroup=group;
    subject.subject=str_subject;
    subject.groupId=group.groupId;
       subject.date =[NSDate date];
    subject.subjectId=[NSString stringWithFormat:@"%@_%@",subject.groupId,[[AppDel xmppStream] generateUUID]];
    
 
    subject.lastupdate =[NSDate date];
    
    return subject;
}

+(BroadcastSubjectSender*)initWithSubject:(NSString*)str_subject subjectId:(NSString*)subjectId groupID:(NSString *)groupid  group:(BroadCastGroup*)group date:(NSString*)sent_timestamp  {
    
    
    
    
    NSFetchRequest *alreadyExists = [[NSFetchRequest alloc] initWithEntityName:@"BroadcastSubjectSender"];
        [alreadyExists  setPredicate:[NSPredicate predicateWithFormat:@"subjectId = %@ ",subjectId  ]];
        NSError *er = nil;
        NSArray *alreadyExistsArr = (NSArray*)[[AppDel managedObjectContext_roster] executeFetchRequest:alreadyExists error:&er];
    
        if([alreadyExistsArr count]!=0)
        {
            return (BroadcastSubjectSender*)[alreadyExistsArr firstObject];
        }
    
    
    

    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    
    BroadcastSubjectSender* subject = [NSEntityDescription insertNewObjectForEntityForName:@"BroadcastSubjectSender" inManagedObjectContext:[AppDel managedObjectContext_roster]];
    
    subject.ofGroup=group;
    subject.subject=str_subject;
    subject.groupId=groupid;
    subject.date = [dateFormatter dateFromString: sent_timestamp];
    subject.subjectId=subjectId;
    subject.lastupdate =[NSDate date];
    
    return subject;
}


@end
