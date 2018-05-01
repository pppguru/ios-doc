//
//  BroadCastMessageDeliveryRecipient+ClassMethod.m
//  IMYourDoc
//
//  Created by vijayveer on 17/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "BroadCastMessageDeliveryRecipient+ClassMethod.h"
#import "BroadCastMessageSender.h"
#import "AppDelegate.h"

@implementation BroadCastMessageDeliveryRecipient (ClassMethod)




+(BroadCastMessageDeliveryRecipient*)initWithRecipientJid:(NSString *)str_receiverJid messageID:(NSString *)str_messageId responseStatus:(BC_ResponseStatusType)responseStauts lastUpdate:(NSDate*)lastupdate ofMessage:(BroadCastMessageSender*)ofmessage  {
    
    BroadCastMessageDeliveryRecipient * recipient = [NSEntityDescription insertNewObjectForEntityForName:@"BroadCastMessageDeliveryRecipient" inManagedObjectContext:[AppDel managedObjectContext_roster]];
    
    recipient.messgeID = str_messageId;
    recipient. receiverJid =str_receiverJid;
    recipient.responseStatus = [NSNumber numberWithInt:responseStauts];
    recipient.responseStatusRead=[NSNumber numberWithInt:responseStauts];
    recipient. lastUpdate = lastupdate;
    recipient.ofMessage= ofmessage;
    
 
    
    [[AppDel managedObjectContext_roster] save:nil];
    
    return recipient;
}





@end
