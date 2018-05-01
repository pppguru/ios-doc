//
//  BroadCastMessageSender+ClassMetod.m
//  IMYourDoc
//
//  Created by vijayveer on 17/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "BroadCastMessageSender+ClassMetod.h"
#import "BroadCastGroup.h"
#import "BroadCastMembers.h"
#import "AppDelegate.h"
#import "BroadCastMessageDeliveryRecipient+ClassMethod.h"
#import "BroadcastSubjectSender+ClassMethod.h"
@implementation BroadCastMessageSender (ClassMetod)
@dynamic  recipientjids;


- (NSArray*)recipientjids
{
    return [[self recipients] valueForKey:@"receiverJid"] ;
}

+(BroadCastMessageSender*)initMessage:(NSString*)str_message  ofsubject:(BroadcastSubjectSender*)subject status:(BCMessageType )status  withSubjectId:(NSString*)str_subjectid{
    
    
     BroadCastMessageSender* senderMessage = [NSEntityDescription insertNewObjectForEntityForName:@"BroadCastMessageSender" inManagedObjectContext:[AppDel managedObjectContext_roster]];
    
    senderMessage.messageId=[[AppDel xmppStream] generateUUID];
    senderMessage.groupId=subject.groupId;
    senderMessage.subjectid=str_subjectid;
    senderMessage.message = str_message;
    senderMessage.status=[NSNumber numberWithInt:status];
    senderMessage.date = [NSDate date];
 
    senderMessage.ofSubject=subject;
    subject.lastupdate=senderMessage.date;
    
    for (BroadCastMembers * member in subject.ofGroup.members)
    {
        
        @autoreleasepool {
            BroadCastMessageDeliveryRecipient *bc= [ BroadCastMessageDeliveryRecipient initWithRecipientJid:member.streamId messageID:senderMessage.messageId responseStatus:BC_ResponseStatusType_Sending lastUpdate:senderMessage.date  ofMessage:senderMessage ];

            
            (void)bc;
        }
        
        
      
    }
    
    
    [[AppDel managedObjectContext_roster] save:nil];
    
    return senderMessage;
    
}



+(BroadCastMessageSender*)initStatTransferMessage:(NSString*)str_message  ofsubject:(BroadcastSubjectSender*)subject status:(BCMessageType )status  withSubjectId:(NSString*)str_subjectid date:(NSString*)sent_timestamp messageID:(NSString*)messageId{
    
  
    
    
        NSFetchRequest *alreadyExists = [[NSFetchRequest alloc] initWithEntityName:@"BroadCastMessageSender"];
        [alreadyExists  setPredicate:[NSPredicate predicateWithFormat:@"messageId = %@ ",messageId  ]];
        NSError *er = nil;
        NSArray *alreadyExistsArr = (NSArray*)[[AppDel managedObjectContext_roster] executeFetchRequest:alreadyExists error:&er];
    
        if([alreadyExistsArr count]!=0)
        {
            return (BroadCastMessageSender*)[alreadyExistsArr firstObject];
        }
    
    
    
//    if(sent_timestamp.length <= 0)
//        sent_timestamp=[NSString stringWithFormat:@"%@", [NSDate date]];
    
    
    
    
    
    BroadCastMessageSender* senderMessage = [NSEntityDescription insertNewObjectForEntityForName:@"BroadCastMessageSender" inManagedObjectContext:[AppDel managedObjectContext_roster]];
    
    senderMessage.messageId=messageId;
    senderMessage.groupId=subject.groupId;
    senderMessage.subjectid=str_subjectid;
    senderMessage.message = str_message;
    senderMessage.status=[NSNumber numberWithInt:status];
    
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    //subject.date =[dateFormatter dateFromString: sent_timestamp];
    
    senderMessage.date = [dateFormatter dateFromString: sent_timestamp];
    if (senderMessage.date==nil)
    {
         [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        senderMessage.date = [dateFormatter dateFromString: sent_timestamp];
    }
    
    
    senderMessage.ofSubject=subject;
    subject.lastupdate=senderMessage.date;
    
    for (BroadCastMembers * member in subject.ofGroup.members)
    {
        @autoreleasepool {
            BroadCastMessageDeliveryRecipient *bc= [ BroadCastMessageDeliveryRecipient initWithRecipientJid:member.streamId messageID:senderMessage.messageId responseStatus:BC_ResponseStatusType_Sending lastUpdate:senderMessage.date  ofMessage:senderMessage ];
            
            (void)bc;
        }
        
        
        
    }
    
    
    [[AppDel managedObjectContext_roster] save:nil];
    
    return senderMessage;
    
}













+(NSString*)getDelievedToWithMessage:(BroadCastMessageSender*)message{
    
    NSMutableString *delievedTo =[[NSMutableString alloc]init];
    NSPredicate *haveMessage= [NSPredicate predicateWithFormat:@"responseStatus = 100"];
    
    NSArray *arr=[[message.recipients  filteredSetUsingPredicate:haveMessage] allObjects];
    [delievedTo appendFormat:@"Delivered to:%lu",(unsigned long)arr.count];
    return delievedTo;
    
}
+(void)setStatusofMessageWhenDelievedWithMessahgId:(NSString*)messageid withRecipitId:(NSString*)recipitentid
{
    {
        NSFetchRequest *alreadyExists = [[NSFetchRequest alloc] initWithEntityName:@"BroadCastMessageSender"];
        
        [alreadyExists setPredicate:[NSPredicate predicateWithFormat:@"messageId == %@", messageid]];
        

        NSArray *alreadyExistsArr = [[AppDel managedObjectContext_roster] executeFetchRequest:alreadyExists error:nil];
        
        
        BroadCastMessageSender *messagebc = [alreadyExistsArr lastObject];
        
        if (messagebc != nil)
        {
            messagebc.status = [NSNumber numberWithInt:BCMessageType_delivered];
            
            
            NSFetchRequest *alBroadCastMessageDeliveryRecipient = [[NSFetchRequest alloc] initWithEntityName:@"BroadCastMessageDeliveryRecipient"];
            
            [alBroadCastMessageDeliveryRecipient setPredicate:[NSPredicate predicateWithFormat:@"receiverJid = %@ AND messgeID =%@", recipitentid,messageid]];
     
            
            NSArray *alreadyExistsArrw = [[AppDel managedObjectContext_roster] executeFetchRequest:alBroadCastMessageDeliveryRecipient error:nil];
            BroadCastMessageDeliveryRecipient *rec = [alreadyExistsArrw lastObject];
            
            if (rec)
            {
                rec.responseStatus=[NSNumber numberWithInt:BC_ResponseStatusType_delivered];
            }
            
            [[AppDel managedObjectContext_roster] save:nil];
        }
    }
    
    
}
+(void)setStatusofMessageWhenReadWithMessahgId:(NSString*)messageid withRecipitId:(NSString*)recipitent
{
    {
        NSFetchRequest *alreadyExists = [[NSFetchRequest alloc] initWithEntityName:@"BroadCastMessageSender"];
        
        [alreadyExists setPredicate:[NSPredicate predicateWithFormat:@"messageId == %@", messageid]];
        
        
        NSArray *alreadyExistsArr = [[AppDel managedObjectContext_roster] executeFetchRequest:alreadyExists error:nil];
        
        
        BroadCastMessageSender *messagebc = [alreadyExistsArr lastObject];
        
        if (messagebc != nil)
        {
            messagebc.status = [NSNumber numberWithInt:BCMessageType_delivered];
            
            
            NSFetchRequest *alBroadCastMessageDeliveryRecipient = [[NSFetchRequest alloc] initWithEntityName:@"BroadCastMessageDeliveryRecipient"];
            
            [alBroadCastMessageDeliveryRecipient setPredicate:[NSPredicate predicateWithFormat:@"receiverJid = %@ AND messgeID =%@", recipitent,messageid]];
            
            
            NSArray *alreadyExistsArrw = [[AppDel managedObjectContext_roster] executeFetchRequest:alBroadCastMessageDeliveryRecipient error:nil];
            BroadCastMessageDeliveryRecipient *rec = [alreadyExistsArrw lastObject];
            
            if (rec)
            {
                rec.responseStatusRead=[NSNumber numberWithInt:BC_ResponseStatusType_Read];
                 rec.responseStatus=[NSNumber numberWithInt:BC_ResponseStatusType_delivered];
            }
            
            [[AppDel managedObjectContext_roster] save:nil];
        }
    }
    
    
}


+(NSString*)getReadByWithMessage:(BroadCastMessageSender*)message
{
    
    
    
    
    
    NSMutableString *delievedTo =[[NSMutableString alloc]init];
    
    
    
    
    
    
    NSPredicate *haveMessage= [NSPredicate predicateWithFormat:@"responseStatusRead = 3"];
    
    NSArray *arr=[[message.recipients  filteredSetUsingPredicate:haveMessage] allObjects];
    
    [delievedTo appendFormat:@"Read by:%lu",(unsigned long)arr.count];
    
    
    return delievedTo;
    
    
    

    
}




+(void)broadcastStateTransferMessages:(NSMutableArray*)arr_messages group:(BroadCastGroup*)group
{
    if(arr_messages.count==0)
        return;
    
    
    
//    NSFetchRequest *alreadyExists = [[NSFetchRequest alloc] initWithEntityName:@"BroadCastGroup"];
//    [alreadyExists  setPredicate:[NSPredicate predicateWithFormat:@"groupId = %@ ",str_groupId  ]];
//    NSError *er = nil;
//    NSArray *alreadyExistsArr = (NSArray*)[[AppDel managedObjectContext_roster] executeFetchRequest:alreadyExists error:&er];
//    
//    if([alreadyExistsArr count]!=0)
//    {
//        return (BroadCastGroup*)[alreadyExistsArr firstObject];
//    }
//    
    
    
  for(id message in arr_messages)
  {
      

      
        
   BroadcastSubjectSender *subject   =
      
      
      
      [BroadcastSubjectSender initWithSubject:[message objectForKey:@"subject"] subjectId:[message objectForKey:@"subject_id"] groupID:[message objectForKey:@"group_id"] group:group  date:[message objectForKey:@"sent_timestamp"]];
      [[AppDel managedObjectContext_roster] save:nil];
      if(subject)
      {
          
        
          @autoreleasepool {
              
                BroadCastMessageSender *msg  =[BroadCastMessageSender initStatTransferMessage:[message objectForKey:@"content"]  ofsubject:subject status:BCMessageType_Read withSubjectId:subject.subjectId date:[message objectForKey:@"sent_Date"] messageID:[message objectForKey:@"message_id"]];
              
              
              (void)msg;
          }
          

          
      
          if([[AppDel managedObjectContext_roster]  hasChanges])
              [[AppDel managedObjectContext_roster] save:nil];
          
          
          
      }
      
      
      
  }
    
    NSLog(@"array Of Messages%@",arr_messages.description);
    
 
    
    
    
    
    
    
}




@end
